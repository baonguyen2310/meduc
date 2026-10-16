<?php
declare(strict_types=1);

namespace App\View\Helper;

use App\Lib\LessonQuizzes;
use Cake\Datasource\ConnectionManager;
use Cake\View\Helper;

/** Read-only dashboard for the signed-in student. Never accept another student's id from a request. */
class MemberDashboardHelper extends Helper
{
    public $helpers = ['Member'];

    public function overview(): array
    {
        $member = $this->Member->getMemberInfo();
        $id = (int)($member['customer_id'] ?? $member['id'] ?? 0);
        $result = ['courses' => [], 'recent' => [], 'week' => [], 'stats' => ['courses' => 0, 'quizzes' => 0, 'attempts' => 0, 'accuracy' => null, 'minutes' => 0, 'days' => 0]];
        if (!$id) return $result;
        $db = ConnectionManager::get('default');

        // Group first: no question/answer bodies are needed for this page.
        $groups = $db->execute(
            'SELECT product_id, quiz_id, COUNT(*) AS attempts, SUM(GREATEST(COALESCE(answer_correct,0),0)) AS correct,
                    SUM(GREATEST(COALESCE(answer_total,0),0)) AS total, SUM(GREATEST(COALESCE(total_time,0),0)) AS seconds, MAX(created) AS last_at
             FROM quizs_answer WHERE deleted = 0 AND customer_id = :member GROUP BY product_id, quiz_id',
            ['member' => $id]
        )->fetchAll('assoc');
        $done = $last = $unique = [];
        $correct = $total = $seconds = 0;
        foreach ($groups as $group) {
            $product = (int)$group['product_id'];
            $quiz = (int)$group['quiz_id'];
            if ($quiz > 0) { $done[$product][$quiz] = true; $unique[$quiz] = true; }
            $last[$product] = max($last[$product] ?? 0, (int)$group['last_at']);
            $result['stats']['attempts'] += (int)$group['attempts'];
            $correct += (int)$group['correct'];
            $total += (int)$group['total'];
            $seconds += (int)$group['seconds'];
        }
        $result['stats']['quizzes'] = count($unique);
        $result['stats']['accuracy'] = $total > 0 ? min(100, (int)round($correct / $total * 100)) : null;
        $result['stats']['minutes'] = (int)round($seconds / 60);

        // Use the existing access rules, including valid enrollments and legacy classroom membership.
        $access = $this->Member->getCourseAccessList();
        $ids = array_values(array_filter(array_map('intval', array_keys($access))));
        if ($ids) {
            $rows = $db->execute(
                "SELECT p.id, p.main_category_id, pc.name, l.url, pa.value AS lessons, pi.images
                 FROM products p
                 LEFT JOIN products_content pc ON pc.product_id = p.id AND pc.lang = :lang
                 LEFT JOIN links l ON l.id = (SELECT MIN(ll.id) FROM links ll WHERE ll.foreign_id = p.id AND ll.type = 'product_detail' AND ll.lang = :lang AND ll.deleted = 0)
                 LEFT JOIN products_attribute pa ON pa.product_id = p.id AND pa.attribute_id = 11
                 LEFT JOIN products_item pi ON pi.id = (SELECT MIN(ii.id) FROM products_item ii WHERE ii.product_id = p.id AND ii.deleted = 0)
                 WHERE p.deleted = 0 AND p.status = 1 AND p.draft = 0 AND p.id IN (" . implode(',', $ids) . ')',
                ['lang' => LANGUAGE]
            )->fetchAll('assoc');
            foreach ($rows as $row) {
                $product = (int)$row['id'];
                $lessons = LessonQuizzes::lessons($row['lessons']);
                $chapters = $lessonCount = 0;
                foreach ($lessons as $lesson) {
                    if (empty($lesson['name_vi'])) continue;
                    if (($lesson['chapter_vi'] ?? '') === 'y') $chapters++;
                    else $lessonCount++;
                }
                $quizIds = LessonQuizzes::ids($lessons);
                $completed = count(array_intersect($quizIds, array_keys($done[$product] ?? [])));
                $images = json_decode((string)$row['images'], true);
                $image = is_array($images) && is_string($images[0] ?? null) ? str_replace('\\', '', $images[0]) : '';
                $url = trim((string)$row['url']);
                $result['courses'][$product] = [
                    'id' => $product, 'name' => trim((string)$row['name']), 'url' => $url !== '' ? '/' . ltrim($url, '/') : '',
                    'image' => $image, 'chapters' => $chapters, 'lessons' => $lessonCount, 'quizzes' => count($quizIds),
                    'done' => $completed, 'percent' => $quizIds ? (int)round($completed / count($quizIds) * 100) : 0,
                    'last_at' => $last[$product] ?? 0, 'expires_at' => (int)($access[$product]['expires_at'] ?? 0),
                    'exam_prep' => (int)$row['main_category_id'] === 125,
                ];
            }
            uasort($result['courses'], function ($a, $b) { return ($b['last_at'] <=> $a['last_at']) ?: ($b['id'] <=> $a['id']); });
            $result['courses'] = array_values($result['courses']);
        }
        $result['stats']['courses'] = count($result['courses']);

        $result['recent'] = $db->execute(
            "SELECT qa.id, qa.product_id, qa.lesson_name, qa.answer_correct, qa.answer_total, qa.total_time, qa.created, qc.name AS quiz_name, pc.name AS course_name
             FROM quizs_answer qa
             LEFT JOIN quizs_content qc ON qc.quiz_id = qa.quiz_id AND qc.lang = :lang
             LEFT JOIN products_content pc ON pc.product_id = qa.product_id AND pc.lang = :lang
             WHERE qa.deleted = 0 AND qa.customer_id = :member ORDER BY qa.created DESC, qa.id DESC LIMIT 5",
            ['lang' => LANGUAGE, 'member' => $id]
        )->fetchAll('assoc');
        foreach ($result['recent'] as &$attempt) {
            $attempt['score'] = (int)$attempt['answer_total'] > 0 ? min(100, (int)round((int)$attempt['answer_correct'] / (int)$attempt['answer_total'] * 100)) : null;
        }
        unset($attempt);

        // PHP uses the application's timezone; avoid the database server's timezone when grouping days.
        $start = strtotime('today -6 days');
        $days = [];
        foreach ($db->execute('SELECT created FROM quizs_answer WHERE deleted = 0 AND customer_id = :member AND created >= :start AND created <= :now', ['member' => $id, 'start' => $start, 'now' => time()])->fetchAll('assoc') as $row) {
            $days[date('Y-m-d', (int)$row['created'])] = true;
        }
        $labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        for ($i = 0; $i < 7; $i++) {
            $day = strtotime('+' . $i . ' days', $start);
            $result['week'][] = ['label' => $labels[(int)date('w', $day)], 'date' => date('d/m', $day), 'done' => isset($days[date('Y-m-d', $day)]), 'today' => $i === 6];
        }
        $result['stats']['days'] = count($days);
        return $result;
    }
}
