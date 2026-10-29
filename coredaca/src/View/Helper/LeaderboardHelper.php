<?php
declare(strict_types=1);

namespace App\View\Helper;

use App\Lib\LessonQuizzes;
use App\Lib\QuizQuestions;
use Cake\Datasource\ConnectionManager;
use Cake\ORM\TableRegistry;
use Cake\View\Helper;

/** Bảng xếp hạng và chỉ số tiến bộ của học viên (block/slider/view_leaderboard.tpl), tính từ lịch sử làm bài (quizs_answer)
 *
 * Điểm của một học viên = tổng số câu đúng ở lần làm tốt nhất của mỗi đề, như bảng xếp hạng lớp học trước đây:
 * làm lại chỉ tính lần cao nhất, nên nộp nhiều lần không làm tăng điểm. Bằng điểm thì ai đúng tỉ lệ cao hơn đứng trước.
 * Tên hiện dạng "N. Minh Anh" (chữ đầu của họ, rồi tên) để không công khai họ tên đầy đủ của học viên.
*/
class LeaderboardHelper extends Helper
{
    const BOARD_SIZE = 50;
    const PERIODS = ['tat-ca' => 'Tất cả', 'thang' => 'Tháng này', 'tuan' => 'Tuần này'];

    /** Các khóa có người làm bài, nhiều lượt làm trước: [['id', 'name', 'url', 'attempts'], ...]
     *
     * {$courses = $this->Leaderboard->getCourses()}
    */
    public function getCourses()
    {
        $rows = $this->db()->execute(
            "SELECT a.product_id AS id, pc.name, l.url, a.attempts
             FROM (SELECT product_id, COUNT(*) AS attempts FROM quizs_answer WHERE deleted = 0 AND product_id > 0 GROUP BY product_id) a
             JOIN products p ON p.id = a.product_id AND p.deleted = 0 AND p.course_kind = 'quiz'
             LEFT JOIN products_content pc ON pc.product_id = a.product_id AND pc.lang = :lang
             LEFT JOIN links l ON l.foreign_id = a.product_id AND l.type = 'product_detail' AND l.lang = :lang AND l.deleted = 0
             ORDER BY a.attempts DESC",
            ['lang' => LANGUAGE]
        )->fetchAll('assoc');

        return array_map(function ($row) {
            return ['id' => (int)$row['id'], 'name' => trim((string)$row['name']), 'url' => '/' . ltrim((string)$row['url'], '/'), 'attempts' => (int)$row['attempts']];
        }, $rows);
    }

    public $helpers = ['Member'];

    /** Khóa của học viên đang đăng nhập: khóa đã làm bài (gần nhất trước), rồi khóa được học mà chưa làm bài
     *  [['id', 'name', 'url'], ...]
     *
     * {$member_courses = $this->Leaderboard->getMemberCourses($member.id)}
    */
    public function getMemberCourses($member_id = 0)
    {
        if (!$member_id) return [];
        $ids = array_map('intval', array_column($this->db()->execute(
            "SELECT product_id, MAX(created) AS last_at FROM quizs_answer WHERE deleted = 0 AND customer_id = :id AND product_id > 0
             GROUP BY product_id ORDER BY last_at DESC",
            ['id' => (int)$member_id]
        )->fetchAll('assoc'), 'product_id'));
        foreach (array_keys($this->Member->getCourseAccessList()) as $product_id) {
            if (!in_array((int)$product_id, $ids, true)) $ids[] = (int)$product_id;
        }
        if (!$ids) return [];

        $rows = $this->db()->execute(
            "SELECT p.id, pc.name, l.url FROM products p
             LEFT JOIN products_content pc ON pc.product_id = p.id AND pc.lang = :lang
             LEFT JOIN links l ON l.foreign_id = p.id AND l.type = 'product_detail' AND l.lang = :lang AND l.deleted = 0
             WHERE p.deleted = 0 AND p.course_kind = 'quiz' AND p.id IN (" . implode(',', $ids) . ")",
            ['lang' => LANGUAGE]
        )->fetchAll('assoc');
        $by_id = [];
        foreach ($rows as $row) {
            $by_id[(int)$row['id']] = ['id' => (int)$row['id'], 'name' => trim((string)$row['name']), 'url' => '/' . ltrim((string)$row['url'], '/')];
        }
        $result = [];
        foreach ($ids as $id) {
            if (isset($by_id[$id])) $result[] = $by_id[$id];
        }
        return $result;
    }

    /** Địa chỉ của trang với khóa, kỳ, tab đang xem, đổi theo $changes (khoa, ky, tab)
     *
     * {$this->Leaderboard->link(['ky' => 'thang'])}
    */
    public function link($changes = [])
    {
        $selection = $this->getSelection();
        $params = array_merge(['khoa' => $selection['product_id'], 'ky' => $selection['period'], 'tab' => $selection['tab']], (array)$changes);
        $query = [];
        if (!empty($params['khoa'])) $query['khoa'] = (int)$params['khoa'];
        if ($params['ky'] !== 'tat-ca') $query['ky'] = $params['ky'];
        if ($params['tab'] === 'tien-bo') $query['tab'] = 'tien-bo';
        return $this->getView()->getRequest()->getPath() . ($query ? '?' . http_build_query($query) : '');
    }

    /** Khóa và kỳ đang xem, theo địa chỉ: ?khoa=id khóa (bỏ trống: mọi khóa), ?ky=tuan|thang|tat-ca
     *  Địa chỉ cũ ?class-room-id=… (bảng xếp hạng của lớp) chuyển thành khóa của lớp đó.
     *
     * {$selection = $this->Leaderboard->getSelection()}
    */
    public function getSelection()
    {
        $request = $this->getView()->getRequest();
        $product_id = (int)$request->getQuery('khoa');
        $class_room_id = (int)$request->getQuery('class-room-id');
        if (!$product_id && $class_room_id) {
            $room = TableRegistry::get('ClassRooms')->find()->where(['id' => $class_room_id, 'deleted' => 0])->select(['product_id'])->first();
            $product_id = !empty($room['product_id']) ? (int)$room['product_id'] : 0;
        }
        $period = (string)$request->getQuery('ky');
        if (!isset(self::PERIODS[$period])) $period = 'tat-ca';
        $tab = $request->getQuery('tab') === 'tien-bo' ? 'tien-bo' : 'bxh';

        return ['product_id' => $product_id, 'period' => $period, 'tab' => $tab];
    }

    /** Bảng xếp hạng của một khóa (0: mọi khóa) trong một kỳ
     *
     * Trả về ['rows' => [['rank', 'customer_id', 'name', 'initials', 'points', 'accuracy', 'quizzes', 'days', 'me'], ...] (tối đa 50),
     *  'me' => dòng của người xem (có cả khi ngoài top 50) hoặc null, 'total' => số người trên bảng, 'range' => 'dd/mm – dd/mm/yyyy']
     *
     * {$board = $this->Leaderboard->getBoard($selection.product_id, $selection.period, $member.id)}
    */
    public function getBoard($product_id = 0, $period = 'tat-ca', $member_id = 0)
    {
        [$from, $range] = $this->periodStart((string)$period);
        $where = 'qa.deleted = 0 AND qa.customer_id > 0 AND qa.created >= :from';
        $bind = ['from' => $from];
        if ($product_id) {
            $where .= ' AND qa.product_id = :product';
            $bind['product'] = (int)$product_id;
        }

        // lần tốt nhất của mỗi đề, rồi cộng theo học viên
        $rows = $this->db()->execute(
            "SELECT best.customer_id, SUM(best.correct) AS points, SUM(best.total) AS total, COUNT(*) AS quizzes,
                    MAX(best.last_at) AS last_at, c.full_name
             FROM (
                SELECT qa.customer_id, qa.quiz_id, MAX(qa.answer_correct) AS correct, MAX(qa.answer_total) AS total, MAX(qa.created) AS last_at
                FROM quizs_answer qa WHERE $where GROUP BY qa.customer_id, qa.quiz_id
             ) best
             JOIN customers c ON c.id = best.customer_id
             GROUP BY best.customer_id, c.full_name
             HAVING points > 0",
            $bind
        )->fetchAll('assoc');

        $days = [];
        foreach ($this->db()->execute(
            "SELECT qa.customer_id, COUNT(DISTINCT FROM_UNIXTIME(qa.created, '%Y-%m-%d')) AS days FROM quizs_answer qa WHERE $where GROUP BY qa.customer_id",
            $bind
        )->fetchAll('assoc') as $row) {
            $days[(int)$row['customer_id']] = (int)$row['days'];
        }

        usort($rows, function ($a, $b) {
            $by_points = (int)$b['points'] <=> (int)$a['points'];
            if ($by_points) return $by_points;
            $accuracy_a = $a['total'] > 0 ? $a['points'] / $a['total'] : 0;
            $accuracy_b = $b['total'] > 0 ? $b['points'] / $b['total'] : 0;
            return ($accuracy_b <=> $accuracy_a) ?: ((int)$a['last_at'] <=> (int)$b['last_at']);
        });

        $result = ['rows' => [], 'me' => null, 'total' => count($rows), 'range' => $range];
        foreach ($rows as $index => $row) {
            $customer_id = (int)$row['customer_id'];
            $line = [
                'rank' => $index + 1,
                'customer_id' => $customer_id,
                'name' => $this->displayName($row['full_name']),
                'initials' => $this->initials($row['full_name']),
                'points' => (int)$row['points'],
                'accuracy' => $row['total'] > 0 ? round($row['points'] / $row['total'] * 100) : 0,
                'quizzes' => (int)$row['quizzes'],
                'days' => $days[$customer_id] ?? 0,
                'me' => $member_id && $customer_id === (int)$member_id
            ];
            if ($line['me']) $result['me'] = $line;
            if ($index < self::BOARD_SIZE) $result['rows'][] = $line;
        }
        return $result;
    }

    /** 7 ngày gần nhất của học viên: [['label' => 'T2'…'CN', 'date' => 'dd/mm', 'done' => có làm bài, 'today'], ...] */
    public function getWeek($member_id = 0)
    {
        $start = strtotime('today -6 days');
        $done = [];
        if ($member_id) {
            foreach ($this->db()->execute(
                "SELECT DISTINCT FROM_UNIXTIME(created, '%Y-%m-%d') AS day FROM quizs_answer WHERE deleted = 0 AND customer_id = :id AND created >= :from",
                ['id' => (int)$member_id, 'from' => $start]
            )->fetchAll('assoc') as $row) {
                $done[$row['day']] = true;
            }
        }

        $labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
        $week = [];
        for ($i = 0; $i < 7; $i++) {
            $time = strtotime('+' . $i . ' days', $start);
            $week[] = ['label' => $labels[(int)date('w', $time)], 'date' => date('d/m', $time), 'done' => !empty($done[date('Y-m-d', $time)]), 'today' => $i === 6];
        }
        return $week;
    }

    /** Chỉ số tiến bộ của một học viên trong một khóa
     *
     * Trả về null khi chưa làm bài nào của khóa, ngược lại:
     * - 'quizzes_done', 'quizzes_total': số đề đã làm / số đề của khóa; 'average': điểm trung bình (lần tốt nhất, thang 100);
     *   'best': điểm cao nhất; 'minutes': tổng thời gian làm bài; 'attempts': số lần nộp;
     * - 'trend': 10 lần nộp gần nhất [['date', 'score', 'quiz']] cho biểu đồ;
     * - 'chapters': tỉ lệ đúng theo chương [['name', 'score', 'questions']] (lần tốt nhất của mỗi đề);
     * - 'mistakes': câu làm sai ở lần làm gần nhất của mỗi đề, mới trước [['quiz', 'lesson', 'question', 'chosen', 'answer', 'explain']] (tối đa 30);
     *   'mistakes_total': tổng số câu sai đó.
     *
     * {$progress = $this->Leaderboard->getProgress($member.id, $course.id)}
    */
    public function getProgress($member_id = 0, $product_id = 0)
    {
        if (!$member_id || !$product_id) return null;

        $attempts = $this->db()->execute(
            "SELECT id, quiz_id, lesson_name, answers, answer_total, answer_correct, answer_correct_percent, total_time, created
             FROM quizs_answer WHERE deleted = 0 AND customer_id = :member AND product_id = :product ORDER BY created ASC, id ASC",
            ['member' => (int)$member_id, 'product' => (int)$product_id]
        )->fetchAll('assoc');
        if (!$attempts) return null;

        // đề và chương của khóa, theo danh sách tiết học
        $lessons_value = TableRegistry::get('ProductsAttribute')->find()->where(['product_id' => (int)$product_id, 'attribute_id' => 11])->select(['value'])->first();
        $lessons = LessonQuizzes::lessons(!empty($lessons_value['value']) ? $lessons_value['value'] : null);
        $chapter_of = [];
        $chapter = 'Bài học';
        foreach ($lessons as $lesson) {
            if (($lesson['chapter_vi'] ?? null) === 'y') {
                $chapter = trim((string)($lesson['name_vi'] ?? '')) ?: $chapter;
                continue;
            }
            foreach (LessonQuizzes::of($lesson) as $quiz) {
                if (!isset($chapter_of[$quiz['id']])) $chapter_of[$quiz['id']] = $chapter;
            }
        }

        $names = [];
        $quiz_ids = array_values(array_unique(array_map('intval', array_column($attempts, 'quiz_id'))));
        foreach (TableRegistry::get('QuizsContent')->find()->where(['quiz_id IN' => $quiz_ids, 'lang' => LANGUAGE])->select(['quiz_id', 'name'])->enableHydration(false) as $row) {
            $names[(int)$row['quiz_id']] = trim((string)$row['name']);
        }

        $best = [];
        $latest = [];
        $seconds = 0;
        foreach ($attempts as $attempt) {
            $quiz_id = (int)$attempt['quiz_id'];
            $seconds += max(0, (int)$attempt['total_time']);
            if (!isset($best[$quiz_id]) || (int)$attempt['answer_correct'] > $best[$quiz_id]['correct']) {
                $best[$quiz_id] = ['correct' => (int)$attempt['answer_correct'], 'total' => max(1, (int)$attempt['answer_total'])];
            }
            $latest[$quiz_id] = $attempt;
        }

        $scores = array_map(function ($item) { return $item['correct'] / $item['total'] * 100; }, $best);
        $by_chapter = [];
        foreach ($best as $quiz_id => $item) {
            $name = $chapter_of[$quiz_id] ?? 'Đề khác';
            if (!isset($by_chapter[$name])) $by_chapter[$name] = ['name' => $name, 'correct' => 0, 'questions' => 0];
            $by_chapter[$name]['correct'] += $item['correct'];
            $by_chapter[$name]['questions'] += $item['total'];
        }
        $chapters = array_values(array_map(function ($item) {
            return ['name' => $item['name'], 'score' => (int)round($item['correct'] / $item['questions'] * 100), 'questions' => $item['questions']];
        }, $by_chapter));

        $trend = array_map(function ($attempt) use ($names) {
            return [
                'date' => date('d/m', (int)$attempt['created']),
                'score' => (int)round((float)$attempt['answer_correct_percent']),
                'quiz' => $names[(int)$attempt['quiz_id']] ?? ('Đề #' . $attempt['quiz_id'])
            ];
        }, array_slice($attempts, -10));

        [$mistakes, $mistakes_total] = $this->mistakes($latest, $names);

        return [
            'quizzes_done' => count($best),
            'quizzes_total' => count(LessonQuizzes::ids($lessons)),
            'average' => (int)round(array_sum($scores) / count($scores)),
            'best' => (int)round(max($scores)),
            'minutes' => (int)round($seconds / 60),
            'attempts' => count($attempts),
            'trend' => $trend,
            'chapters' => $chapters,
            'mistakes' => $mistakes,
            'mistakes_total' => $mistakes_total
        ];
    }

    /** Câu sai ở lần làm gần nhất của mỗi đề. Câu được tìm theo vị trí (bài làm từ trình làm bài mới), hoặc theo mã câu
     *  khi mã đó không trùng trong đề (bài làm cũ). Câu bỏ trống không tính. */
    private function mistakes($latest, $names)
    {
        uasort($latest, function ($a, $b) { return (int)$b['created'] <=> (int)$a['created']; });
        $values = [];
        if ($latest) {
            foreach (TableRegistry::get('QuizsAttribute')->find()->where([
                'quiz_id IN' => array_keys($latest), 'attribute_id' => QuizQuestions::QUESTIONS_ATTRIBUTE
            ])->select(['quiz_id', 'value'])->enableHydration(false) as $row) {
                $values[(int)$row['quiz_id']] = $row['value'];
            }
        }

        $result = [];
        $total = 0;
        foreach ($latest as $quiz_id => $attempt) {
            $answers = json_decode((string)$attempt['answers'], true);
            if (!is_array($answers) || empty($values[$quiz_id])) continue;
            $questions = QuizQuestions::fromValue($values[$quiz_id]);
            $by_code = [];
            foreach ($questions as $index => $question) {
                if ($question['code'] === '') continue;
                $by_code[$question['code']] = isset($by_code[$question['code']]) ? -1 : $index;
            }

            foreach ($answers as $answer) {
                if (!is_array($answer) || empty($answer['answer'])) continue;
                $index = isset($answer['index']) && is_numeric($answer['index']) ? (int)$answer['index']
                    : (isset($answer['code'], $by_code[$answer['code']]) ? $by_code[$answer['code']] : -1);
                if ($index < 0 || empty($questions[$index])) continue;
                $question = $questions[$index];
                $chosen = (int)$answer['answer'];
                if ($question['answer'] <= 0 || $chosen === $question['answer']) continue;

                $total++;
                if (count($result) >= 30) continue;
                $option = function ($value) use ($question) {
                    foreach ($question['options'] as $item) if ($item[0] === $value) return chr(64 + $value) . '. ' . $item[1];
                    return '';
                };
                $result[] = [
                    'quiz' => $names[$quiz_id] ?? ('Đề #' . $quiz_id),
                    'lesson' => trim((string)$attempt['lesson_name']),
                    'number' => $index + 1,
                    'question' => $question['question'],
                    'chosen' => $option($chosen),
                    'answer' => $option($question['answer']),
                    'explain' => $question['explain']
                ];
            }
        }
        return [$result, $total];
    }

    /** Thời điểm bắt đầu kỳ và nhãn khoảng ngày của kỳ */
    private function periodStart($period)
    {
        $now = time();
        if ($period === 'tuan') {
            $from = strtotime('monday this week', $now);
            return [$from, date('d/m', $from) . ' – ' . date('d/m/Y', $now)];
        }
        if ($period === 'thang') {
            $from = strtotime(date('Y-m-01 00:00:00', $now));
            return [$from, date('d/m', $from) . ' – ' . date('d/m/Y', $now)];
        }
        return [0, 'Đến ' . date('d/m/Y', $now)];
    }

    /** "Nguyễn Minh Anh" → "N. Minh Anh"; một chữ thì giữ nguyên */
    private function displayName($full_name)
    {
        $words = preg_split('/\s+/u', mb_convert_case(trim((string)$full_name), MB_CASE_TITLE, 'UTF-8'), -1, PREG_SPLIT_NO_EMPTY);
        if (!$words) return 'Học viên MedUC';
        if (count($words) === 1) return $words[0];
        $family = array_shift($words);
        if (count($words) > 2) $words = array_slice($words, -2);
        return mb_strtoupper(mb_substr($family, 0, 1)) . '. ' . implode(' ', $words);
    }

    /** "Nguyễn Minh Anh" → "MA" */
    private function initials($full_name)
    {
        $words = preg_split('/\s+/u', trim((string)$full_name), -1, PREG_SPLIT_NO_EMPTY);
        if (!$words) return 'M';
        $last = array_slice($words, -2);
        return mb_strtoupper(implode('', array_map(function ($word) { return mb_substr($word, 0, 1); }, $last)));
    }

    private function db()
    {
        return ConnectionManager::get('default');
    }
}
