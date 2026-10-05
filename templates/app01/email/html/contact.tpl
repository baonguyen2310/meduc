{assign var = contact value = $this->Contact->getDetailContact($id_record)}
{assign var = contact_info value = []}
{if !empty($contact.value)}
    {assign var = contact_info value = $contact.value} 
{/if}

<div style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;margin-bottom:10px">
    {if $contact_info.cartId}
        Đơn đặt hàng (Sách và Thiết bị y tế)
    {else}
        {__d('template', 'khach_hang_de_lai_thong_tin_lien_he')}
    {/if}
</div>
{if !empty($contact_info)}
    <table style="border-collapse:collapse;border: 1px solid #e5e5e5;" align="left" border="0" cellpadding="0" cellspacing="0" width="100%">
	    <thead>
	        <tr>
	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;padding:10px 15px;background-color: #36414b;color:#ffffff; text-align: left;"  width="30%">
	                <b>{__d('template', 'thong_tin_lien_he')}: </b>
	            </th>
	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;padding:10px 15px;background-color: #36414b;color:#ffffff; text-align: left;" width="70%"></th>
	        </tr>
	    </thead>
	    <tbody>
	        {if !empty($contact_info.cartId)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                Mã đơn hàng
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.cartId}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.full_name)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                {__d('template', 'ho_va_ten')}
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.full_name}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.phone)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                {__d('template', 'so_dien_thoai')}
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.phone}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.email)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                Email
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.email}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.address)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                Địa chỉ
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.address}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.title)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                {__d('template', 'tieu_de')}
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.title}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.content)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                {__d('template', 'noi_dung')}
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.content}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.note)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                Ghi chú
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>{$contact_info.note}</strong>
    	            </td>
    	        </tr>
	        {/if}
	        {if !empty($contact_info.payment)}
    	        <tr>
    	            <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050; padding:5px 10px;">
    	                Phương thức thanh toán
    	            </td>
    	            <td  style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color: #505050;padding:5px 10px;">
                        <strong>
                            {if $contact_info.payment == "cod"}
                                Ship COD
                            {/if}
                            {if $contact_info.payment == "bank"}
                                Chuyển khoản
                            {/if}
                        </strong>
    	            </td>
    	        </tr>
	        {/if}
	    </tbody>
	</table>
	
	{if !empty($contact_info.cartProducts)}
    	{assign var = cartProducts value = $this->Contact->getDetailCart($contact_info.cartProducts)}
    	{assign var = "total" value = 0}
        {foreach $cartProducts as $product}
            {assign var = "total" value = $total+$product.total}
        {/foreach}
    	<table style="border-collapse:collapse;border: 1px solid #e5e5e5;" align="left" border="0" cellpadding="0" cellspacing="0" width="100%">
    	    <thead>
    	        <tr>
    	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
    	                STT
    	            </th>
    	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
    	                Tên sản phẩm
    	            </th>
    	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
    	                Số lượng
    	            </th>
    	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
    	                Giá
    	            </th>
    	            <th style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
    	                Thành tiền
    	            </th>
    	        </tr>
    	    </thead>
    	    <tbody>
    	        {foreach from = $cartProducts item = product key = key}   
                    <tr>
                        <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
                            {$key + 1}
                        </td>
                        <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
                            {$product.name}
                        </td>
                        <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
                            {$product.quantity}
                        </td>
                        <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px">
                            {$product.price_special|number_format:0:".":","} VND
                        </td>
                        <td style="border-collapse:collapse;font-family:Helvetica,Arial;font-size:12px;line-height:150%;text-align:left;color:#505050;padding:5px 10px" class="text-right">
                            {$product.total|number_format:0:".":","} VND
                        </td>
                    </tr>
                {/foreach}
    	    </tbody>
    	</table>
    	<p>Tổng tiền: <b>{$total|number_format:0:".":","} VND</b></p>
	{/if}
{/if}