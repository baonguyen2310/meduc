{assign var=question_metadata_labels value=$this->Utilities->questionMetadataLabels($question)}
{if !empty($question_metadata_labels)}
    <div class="d-flex flex-wrap gap-2 mb-15">
        {foreach from=$question_metadata_labels key=metadata_field item=metadata_label}
            <span class="badge bg-light text-dark border px-2 py-1" title="{if $metadata_field == 'difficulty_level'}Mức độ{else}Loại câu hỏi{/if}: {$metadata_label|escape}">{$metadata_label|escape}</span>
        {/foreach}
    </div>
{/if}
