<?php
namespace Admin\Controller;

use App\Service\ThemeUsage;
use Cake\Event\EventInterface;
use Cake\Http\Exception\ForbiddenException;

class ThemeUsageController extends AppController
{
    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
        if ($this->Auth->user('id') && (!defined('MEDUC_FA_ADMIN') || !MEDUC_FA_ADMIN)) {
            throw new ForbiddenException('Chỉ quản trị viên được xem lịch sử giao diện.');
        }
    }

    public function index()
    {
        $view = (string)$this->request->getQuery('view', 'history');
        if (!in_array($view, ['history', 'users', 'browsers'], true)) $view = 'history';
        $theme = (string)$this->request->getQuery('theme', 'all');
        if (!in_array($theme, ['all', 'light', 'dark'], true)) $theme = 'all';
        $reasons = ['change'=>'Người dùng đổi', 'reset'=>'Đặt lại mặc định sáng', 'initial'=>'Ghi nhận lần đầu',
            'account_sync'=>'Đồng bộ từ tài khoản', 'browser_sync'=>'Đồng bộ trình duyệt'];
        $reason = (string)$this->request->getQuery('reason', 'all');
        if (!isset($reasons[$reason])) $reason = 'all';
        $q = mb_substr(trim((string)$this->request->getQuery('q', '')), 0, 150);
        $customer = max(0, (int)$this->request->getQuery('customer'));
        $browser = strtolower((string)$this->request->getQuery('browser', ''));
        if (!preg_match('/^[a-f0-9]{12,64}$/', $browser)) $browser = '';
        $rows = []; $total = 0; $page = 1; $pages = 1;
        $theme_usage = ThemeUsage::summary();
        if ($theme_usage['installed']) {
            $table = ['history'=>'theme_usage_events', 'users'=>'theme_usage_customers', 'browsers'=>'theme_usage_browsers'][$view];
            $where = ['1=1']; $params = [];
            if ($theme !== 'all') { $where[] = 't.theme=:theme AND t.preference_version=:version'; $params += ['theme'=>$theme, 'version'=>ThemeUsage::VERSION]; }
            if ($view === 'history' && $reason !== 'all') { $where[] = 't.reason=:reason'; $params['reason'] = $reason; }
            if ($customer) { $where[] = 't.customer_id=:customer'; $params['customer'] = $customer; }
            if ($browser && $view !== 'users') { $where[] = 't.browser_key LIKE :browser'; $params['browser'] = $browser . '%'; }
            if ($q !== '') {
                $where[] = '(c.full_name LIKE :name OR c.email LIKE :email OR c.code LIKE :code' . ($view !== 'users' ? ' OR t.browser_key LIKE :browser_search' : '') . ')';
                $params += ['name'=>'%'.$q.'%', 'email'=>'%'.$q.'%', 'code'=>'%'.$q.'%'];
                if ($view !== 'users') $params['browser_search'] = $q . '%';
            }
            $sql = " FROM {$table} t LEFT JOIN customers c ON c.id=t.customer_id WHERE " . implode(' AND ', $where);
            $db = ThemeUsage::db();
            $total = (int)$db->execute('SELECT COUNT(*)' . $sql, $params)->fetchColumn(0);
            $pages = max(1, (int)ceil($total / 50));
            $page = min($pages, max(1, (int)$this->request->getQuery('page', 1)));
            $offset = ($page - 1) * 50;
            $order = $view === 'history' ? 't.id DESC' : 't.last_seen DESC, t.customer_id DESC';
            $rows = $db->execute('SELECT t.*, c.full_name, c.email, c.code AS customer_code' . $sql . " ORDER BY {$order} LIMIT 50 OFFSET {$offset}", $params)->fetchAll('assoc');
            foreach ($rows as &$row) {
                $row['browser_label'] = isset($row['browser_key']) ? substr($row['browser_key'], 0, 12) : '';
                $row['current'] = (int)$row['preference_version'] === ThemeUsage::VERSION;
            }
            unset($row);
        }
        $filters = ['view'=>$view, 'theme'=>$theme, 'reason'=>$reason, 'q'=>$q, 'customer'=>$customer, 'browser'=>$browser];
        $previous_url = '?' . http_build_query($filters + ['page'=>max(1, $page - 1)]);
        $next_url = '?' . http_build_query($filters + ['page'=>min($pages, $page + 1)]);
        $this->set(compact('view', 'theme', 'reason', 'reasons', 'q', 'customer', 'browser', 'rows', 'total', 'page', 'pages', 'theme_usage', 'previous_url', 'next_url'));
        $this->set('path_menu', 'theme-usage');
        $this->set('title_for_layout', 'Giao diện sáng / tối');
    }
}
