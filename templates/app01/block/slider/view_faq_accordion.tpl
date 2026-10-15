{strip}
{* Frequently asked questions in MasterClass style: a list of questions, each opening its answer (native <details>).
   Items: Name = the question (a leading "Câu hỏi 1:" is dropped), Mô tả = the answer, one point per line.
   Text: tieu_de (the heading). Styles: assets/meduc-v2/classroom.css (the course page shows this block). *}
{assign var = text value = []}
{if !empty($data_extend.locale[{LANGUAGE}])}
    {assign var = text value = $data_extend.locale[{LANGUAGE}]}
{/if}
{if !empty($data_block)}
<div class="mfq">
    <h2 class="mfq-title">{if !empty($text.tieu_de)}{$text.tieu_de|escape}{else}Câu hỏi thường gặp{/if}</h2>
    <div class="mfq-list">
        {foreach from = $data_block item = item}
            {if empty($item.name)}{continue}{/if}
            {$question = $item.name|regex_replace:'/^\s*câu\s+hỏi\s*\d+\s*:\s*/iu':''|regex_replace:'/\s+/u':' '|trim}
            <details class="mfq-item">
                <summary>
                    <span>{$question|escape}</span>
                    <svg class="mfq-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14" /></svg>
                </summary>
                {if !empty($item.description)}<div class="mfq-answer">{$item.description|trim|escape|nl2br}</div>{/if}
            </details>
        {/foreach}
    </div>
</div>
{/if}
{/strip}
