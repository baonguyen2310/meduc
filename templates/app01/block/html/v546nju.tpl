{strip}{assign memberInfo value = $this->Member->getMemberInfo()}

{if !empty($memberInfo)}
    {assign var = listHistoryQuiz value = $this->Utilities->getListHistoryQuiz($memberInfo.code)}
    
    <div class="my-40 fs-13">
        {if !empty($listHistoryQuiz) && count($listHistoryQuiz) > 0}
            <div class="table-responsive shadow-sm rounded-3 overflow-hidden border">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr class="text-uppercase text-secondary fs-12">
                            <th scope="col" class="py-3 px-3">Tên lớp học</th>
                            <th scope="col" class="py-3">Tên bài tập</th>
                            <th scope="col" class="py-3 text-center">Số câu đúng</th>
                            <th scope="col" class="py-3 text-center">Tổng thời gian</th>
                            <th scope="col" class="py-3 text-center">Ngày làm</th>
                            <th scope="col" class="py-3 text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from = $listHistoryQuiz item = item}
                            <tr>
                                <td class="px-3 fw-semibold text-dark">{$item.class_name}</td>
                                <td>
                                    <span class="text-primary fw-medium">{$item.quiz_name}</span>
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1 fs-12 fw-bold">
                                        {$item.answer_correct}/{$item.answer_total}
                                    </span>
                                </td>
                                <td class="text-center text-muted">{$item.total_time}</td>
                                <td class="text-center text-muted">{$this->Utilities->convertIntgerToDateTimeString($item.created)}</td>
                                <td class="text-center">
                                    <a href="/ket-qua-bai-tap?id={$item.id}" class="btn btn-sm btn-primary px-3 rounded-pill">
                                        Xem kết quả
                                    </a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            <div class="text-center py-5 px-4 bg-light rounded-3 border">
                <div class="mb-3">
                    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="#6c757d" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="d-inline-block text-muted">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="16" y1="13" x2="8" y2="13"></line>
                        <line x1="16" y1="17" x2="8" y2="17"></line>
                        <polyline points="10 9 9 9 8 9"></polyline>
                    </svg>
                </div>
                <h5 class="fw-bold text-dark mb-2">Bạn chưa có lịch sử làm bài tập nào</h5>
                <p class="text-muted mb-4 fs-14" style="max-width: 480px; margin: 0 auto;">
                    Hãy chọn một bài tập hoặc đề thi trắc nghiệm trong ngân hàng đề để bắt đầu ôn luyện và theo dõi kết quả tại đây!
                </p>
                <a href="/danh-sach-de-thi" class="btn btn-primary px-4 py-2 rounded-pill fw-medium">
                    <i class="feather-book-open me-1"></i> Bắt đầu luyện thi ngay
                </a>
            </div>
        {/if}
    </div>
{else}
    <div class="my-60 text-center py-5 px-4 bg-light rounded-3 border">
        <h5 class="fw-bold text-dark mb-2">Vui lòng đăng nhập để xem lịch sử làm bài</h5>
        <p class="text-muted mb-4 fs-14">Đăng nhập tài khoản học viên để tra cứu lịch sử và bảng điểm bài thi của bạn.</p>
        <a href="/member/login" class="btn btn-primary px-4 py-2 rounded-pill fw-medium">
            Đăng nhập ngay
        </a>
    </div>
{/if}{/strip}