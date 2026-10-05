{assign var = contact value = []}
{if !empty($order_info.contact)}
	{assign var = contact value = $order_info.contact}
{/if}

<div class="entry-account-detail">
	{if !empty($contact.full_name)}
		<p class="mb-0">
			Họ tên: <strong>{$contact.full_name}</strong>
		</p>
	{/if}

	{if !empty($contact.phone)}
		<p class="mb-0">
			Số điện thoại: <strong>{$contact.phone}</strong>
		</p>
	{/if}
	
	{if !empty($contact.email)}
		<p class="mb-0">
			Email: <strong>{$contact.email}</strong>
		</p>
	{/if}

	{*if !empty($contact.full_address)}
		<p class="mb-0">
			{$contact.full_address}
		</p>
	{/if*}

	{if !empty($order_info.note)}
		<p class="mb-0">
			{__d('template', 'ghi_chu')}: {$order_info.note}
		</p>
	{/if}
</div>