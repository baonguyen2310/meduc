<?php

namespace App\Controller;

use Cake\Event\EventInterface;
use Cake\ORM\TableRegistry;
use Cake\Datasource\ConnectionManager;

class MasterclassController extends AppController 
{
    public function initialize(): void
    {
        parent::initialize();
        $this->get_structure_layout = false;
    }

    public function beforeFilter(EventInterface $event)
    {
        parent::beforeFilter($event);
    }

    /**
     * MasterClass Homepage (White Luxury Theme)
     */
    public function index()
    {
        $this->set('title_for_layout', 'MedUC MasterClass - Học Y Khoa Từ Chuyên Gia Hàng Đầu');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('index');
    }

    /** Light Meduc introduction, paired with the redesigned homepage. */
    public function about()
    {
        $this->set('title_for_layout', 'Giới thiệu Meduc — Học Y có người đồng hành');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('about');
    }

    /** Student feedback preview using Meduc's existing review and video content. */
    public function feedback()
    {
        $this->set('title_for_layout', 'Phản hồi học viên — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('feedback');
    }

    /** Light course catalog preview, based on the audited enabled course list. */
    public function coursesV2()
    {
        $this->set('title_for_layout', 'Danh sách khóa học — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('courses_v2');
    }

    /** Light course detail preview for enabled Meduc courses. */
    public function courseDetailV2()
    {
        $this->set('title_for_layout', 'Chi tiết khóa học — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('course_detail_v2');
    }

    /** Light catalog preview for enabled Meduc medical books. */
    public function booksV2()
    {
        $this->set('title_for_layout', 'Sách Y khoa — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('books_v2');
    }

    /** Light detail preview for active Meduc books. */
    public function bookDetailV2()
    {
        $this->set('title_for_layout', 'Chi tiết sách Y khoa — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('book_detail_v2');
    }

    /** Light list preview for enabled Meduc study documents. */
    public function documentsV2()
    {
        $this->set('title_for_layout', 'Tài liệu học tập — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('documents_v2');
    }

    /** Light detail preview for an enabled Meduc study resource. */
    public function resourceDetailV2()
    {
        $this->set('title_for_layout', 'Chi tiết tài liệu — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('resource_detail_v2');
    }

    /** Light checkout interface preview for enabled courses and books. */
    public function checkoutV2()
    {
        $this->set('title_for_layout', 'Thanh toán — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('checkout_v2');
    }

    /** Light catalog preview for enabled Meduc blog articles. */
    public function blogV2()
    {
        $this->set('title_for_layout', 'Blog Y khoa — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('blog_v2');
    }

    /** Light detail preview for an enabled Meduc blog article. */
    public function blogDetailV2()
    {
        $this->set('title_for_layout', 'Chi tiết blog — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('blog_detail_v2');
    }

    /** Light preview of the student's participating courses. */
    public function myCoursesV2()
    {
        $this->set('title_for_layout', 'Khóa học đang tham gia — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('my_courses_v2');
    }

    /** Light course recommendation flow using the enabled Meduc course catalog. */
    public function recommendationsV2()
    {
        $this->set('title_for_layout', 'Khóa học dành cho bạn — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('recommendations_v2');
    }

    /** Light Facourse exam index grouped by school, title year and subject/module. */
    public function examHierarchyV2()
    {
        $this->set('title_for_layout', 'Hệ thống bộ đề — Meduc');
        $this->viewBuilder()->disableAutoLayout();
        $this->render('exam_hierarchy_v2');
    }

    /**
     * Dedicated Medical Course Catalog / Listing Page
     */
    public function courses()
    {
        $conn = ConnectionManager::get('default');

        // Fetch real flagship courses from DB
        $courses = $conn->execute("
            SELECT 
                p.id, 
                pc.name, 
                pc.description,
                pi.price, 
                pi.price_special,
                l.url
            FROM products p 
            JOIN products_content pc ON p.id = pc.product_id 
            LEFT JOIN products_item pi ON p.id = pi.product_id 
            LEFT JOIN links l ON l.foreign_id = p.id AND l.type = 'product_detail'
            WHERE p.deleted = 0 AND p.status = 1 
            GROUP BY p.id 
            ORDER BY p.id DESC 
            LIMIT 24
        ")->fetchAll('assoc');

        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('courses', $courses);
        $this->set('member', $member);
        $this->set('title_for_layout', 'Danh Mục Khóa Học Y Khoa Toàn Diện - MedUC MasterClass');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('courses');
    }

    /**
     * Redesigned Course Detail Page (MasterClass Cinematic Style)
     */
    public function courseDetail()
    {
        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('member', $member);
        $this->set('title_for_layout', 'Ngoại Cơ Sở & Khám Bệnh Ngoại Khoa Thực Chiến - MedUC MasterClass');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('course_detail');
    }

    /**
     * Redesigned Checkout Page (Frictionless with VietQR Auto-Match)
     */
    public function checkout()
    {
        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('member', $member);
        $this->set('title_for_layout', 'Thanh Toán Đơn Hàng & Kích Hoạt Khóa Học - MedUC');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('checkout');
    }

    /**
     * Redesigned Student Learning Portal (Gamified with Streak & MedDuo)
     */
    public function portal()
    {
        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('member', $member);
        $this->set('title_for_layout', 'Cổng Học Viên Y Khoa MedUC - Tiến Độ & Luyện Thi');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('portal');
    }

    /**
     * Redesigned Medical Journal Article & Case Study Reader
     */
    public function articleDetail()
    {
        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('member', $member);
        $this->set('title_for_layout', 'Tiếp Cận & Xử Trí Nhanh Cơn Đau Ngực Cấp - Tạp Chí Y Khoa MedUC');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('article_detail');
    }

    /**
     * Interactive Features & Roadmap Dashboard (Executive Presentation)
     */
    public function features()
    {
        $session = $this->request->getSession();
        $member = $session->read('member') ?: (defined('MEMBER') ? $session->read(MEMBER) : []);

        $this->set('member', $member);
        $this->set('title_for_layout', 'Bản Đồ Chiến Lược Tính Năng & Trải Nghiệm MedUC 2026');

        $this->viewBuilder()->disableAutoLayout();
        $this->render('features');
    }
}
