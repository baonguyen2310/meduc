{strip}<nav class="breadcrumbs-section">
	<a href="/">
	    {__d('template', 'trang_chu')}
	</a>
	{if !empty($breadcrumb)}
	    {foreach from = $breadcrumb item = item name = breadcrumb_each}
	        {if !$smarty.foreach.breadcrumb_each.last}
	            {if !empty($item.url)}
    	            <a href="{$this->Utilities->checkInternalUrl($item.url)}">
    	                {if !empty($item.name)}
    	                
    	                    {$item.name|escape|truncate:50:" ..."}
    	                {/if}
    	            </a>
	            {/if}
	        {else}
	            <h1>
	                <a href="{$this->Utilities->checkInternalUrl($item.url)}">
    	                <span>
                    	    {if !empty($item.name)}
        	                    {$item.name|escape|truncate:50:" ..."}
        	                {/if}
                	    </span>
            	    </a>
            	</h1>
	        {/if}
	    {/foreach}
	{/if}
</nav>{/strip}