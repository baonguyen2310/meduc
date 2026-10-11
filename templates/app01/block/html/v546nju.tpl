{strip}{assign memberInfo value = $this->Member->getMemberInfo()}

{if !empty($memberInfo)}
    {assign var = listHistoryQuiz value = $this->Utilities->getListHistoryQuiz($memberInfo.code)}
    
    <div class="my-60 fs-12">
        <table class="table">
            <thead class="table-light">
                <tr>
                    <th scope="col">Tên lớp học</th>
                    <th scope="col">Tên bài tập</th>
                    <th scope="col">Số câu đúng</th>
                    <th scope="col">Tổng thời gian</th>
                    <th scope="col">Ngày làm</th>
                    <th scope="col">Hành động</th>
                </tr>
            </thead>
            <tbody>
                {foreach from = $listHistoryQuiz item = item}
                    <tr>
                        <td scope="col">{$item.class_name}</td>
                        <td scope="col">{$item.quiz_name}</td>
                        <td scope="col">{$item.answer_correct}/{$item.answer_total}</td>
                        <td scope="col">{$item.total_time}</td>
                        <td scope="col">{$this->Utilities->convertIntgerToDateTimeString($item.created)}</td>
                        <td scope="col">
                            <a href="/ket-qua-bai-tap?id={$item.id}" class="btn btn-primary">
                                Kết quả
                            </a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
{/if}{/strip}