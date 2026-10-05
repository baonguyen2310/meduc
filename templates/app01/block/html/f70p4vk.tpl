{strip}{assign memberInfo value = $this->Member->getMemberInfo()}
{assign var = classRoomId value = $this->Utilities->getParamsByKey('class-room-id')}
{assign var = url value = $this->Utilities->getParamsByKey('url')}

{if !empty($memberInfo) && !empty($classRoomId)}
    {assign var = classRoom value = $this->Utilities->checkExistMemberInClassRoom($memberInfo.code, $classRoomId)}
    {if !empty($classRoom)}
        {assign var = productAttribute value = $this->Utilities->getListQuiz($classRoom.product_id, 11)}
        
        {if !empty($classRoom.class_name)}
            <h4 class="text-center">
                <a href="{if !empty($url)}{$url}{/if}">
                    {$classRoom.class_name}
                </a>
            </h4>
        {/if}
        
        <div class="table-rank" scroll-table>
            <table class="table table-bordered">
                <thead class="table-light">
                    <tr>
                        <th scope="col">Thứ Hạng</th>
                        <th scope="col">Họ Tên</th>
                        <th scope="col">Tổng Điểm</th>
                        {foreach from = $productAttribute item = item}
                            <th scope="col" quiz-id="{$item.quiz_id}">
                                {$item.name}
                            </th>
                        {/foreach}
                    </tr>
                </thead>
                <tbody>
                    {foreach from = $classRoom.users item = user key = key}
                        <tr class="{$user.color}">
                            <td scope="col" class="fs-13">
                                {$key + 1}
                            </td>
                            <td scope="col" class="{if $memberInfo.code == $user.code}my-user{/if}">
                                <div class="inner-fullname">
                                    <div class="fs-13 fw-bold" style="white-space: nowrap;">
                                        {$user.full_name}
                                    </div>
                                    <div class="fs-11">
                                        {$user.code}
                                    </div>
                                </div>
                            </td>
                            <td scope="col">
                                <div class="inner-fullname">
                                    <div class="fs-12" style="white-space: nowrap;">
                                        Tổng điểm: <strong>{$user.total_point}</strong>
                                    </div>
                                    <div class="fs-12" style="white-space: nowrap;">
                                        Thời gian: <strong>{$user.total_time}</strong>
                                    </div>
                                </div>
                            </td>
                            {foreach from = $productAttribute item = item}
                                {assign var = itemQuiz value = null}
                                {if !empty($user.listAnswer)}
                                    {foreach from = $user.listAnswer item = answer}
                                        {if $answer.quiz_id == $item.quiz_id}
                                            {assign var = itemQuiz value = $answer}
                                        {/if}
                                    {/foreach}
                                {/if}
                                <td scope="col" quiz-id="{$item.quiz_id}" class="fs-12">
                                    {if !empty($itemQuiz)}
                                        <div>Đúng: <strong>{$itemQuiz.answer_correct_max}</strong>/<strong>{$itemQuiz.answer_total}</strong></div>
                                        <div>Thời gian: <strong>{$itemQuiz.total_time}</strong></div>
                                        <div>Số lần: <strong>{$itemQuiz.repeat}</strong></div>
                                    {else}
                                        <div>Chưa làm</div>
                                    {/if}
                                </td>
                            {/foreach}
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {/if}
{/if}{/strip}