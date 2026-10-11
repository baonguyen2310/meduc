{strip}
{if !empty($categories)}
	{foreach from = $categories item = category}
	    <div class="col-xl-3 col-md-4 col-sm-6 col-6 mb-30">
            <div class="single-team">
                <a {if !empty($category.url)}href="{$this->Utilities->checkInternalUrl($category.url)}"{/if}>
                    <div class="team-thumb">
                        <div class="brd">
                            <img src="{CDN_URL}{$category.image_avatar}" alt="img" />
                        </div>
                    </div>
                    <div class="team-info">
                        <h4>
                            {$category.name}
                        </h4>
                    </div>
                </a>
            </div>
        </div>
	{/foreach}
{/if}
{/strip}