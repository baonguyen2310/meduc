{strip}
{if PAGE_TYPE == PRODUCT_DETAIL && !empty(PAGE_RECORD_ID)}
    {$recommendations = $this->Product->getRelatedAcademyCourses(PAGE_RECORD_ID)}
    {$this->element('course/recommendation_cards', ['recommendations' => $recommendations, 'section_id' => 'related-courses'])}
{/if}
{/strip}
