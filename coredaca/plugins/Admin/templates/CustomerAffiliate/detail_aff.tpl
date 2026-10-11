{if !empty($customer)}
    {assign var = url_list value = "{ADMIN_PATH}/customer/aff"}

    <div class="kt-subheader   kt-grid__item" id="kt_subheader">
        <div class="kt-container  kt-container--fluid ">
            <div class="kt-subheader__main">
                <h3 class="kt-subheader__title">
                    {if !empty($title_for_layout)}{$title_for_layout}{/if}
                </h3>
            </div>

            <div class="kt-subheader__toolbar">
                <a href="{$url_list}" class="btn btn-sm btn-default">
                    {__d('admin', 'quay_lai_danh_sach')}
                </a>
            </div>
        </div>
    </div>

    <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
        <div class="kt-portlet kt-portlet--tabs">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Thông tin đối tác
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                {__d('admin', 'ho_va_ten')}
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.full_name)}
                                        {$customer.full_name}
                                    {/if}
                                </span>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Mã đối tác
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.code)}
                                        {$customer.code}
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                {__d('admin', 'so_dien_thoai')}
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.phone)}
                                        {$customer.phone}
                                    {/if}
                                </span>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                {__d('admin', 'email')}
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.email)}
                                        {$customer.email}
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Tổng tiền hoa hồng
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.affiliate_amount)}
                                        {$customer.affiliate_amount|number_format:0:".":","} VNĐ
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Hoa hồng chưa thanh toán
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.affiliate_amount_unpaid)}
                                        {$customer.affiliate_amount_unpaid|number_format:0:".":","} VNĐ
                                    {/if}
                                </span>
                                <button class="btn btn-info" button-accept-payment-affiliate data-link="/admin/customer/aff/accept-payment/{$customer.id}">Duyệt thanh toán</button>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Hoa hồng đã thanh toán
                            </label>
                        
                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.affiliate_amount) && !empty($customer.affiliate_amount_unpaid)}
                                        {math 
                                            equation="a - b" 
                                            a=$customer.affiliate_amount+0 
                                            b=$customer.affiliate_amount_unpaid+0 
                                            assign=affiliate_amount_paid
                                        }
                                        {if isset($affiliate_amount_paid)}
                                            {$affiliate_amount_paid|number_format:0:".":","} VNĐ
                                        {/if}
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                % Hoa hồng của đối tác
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <input input-change-percent data-link="/admin/customer/aff/change-affiliate-percent/{$customer.id}" value="{if !empty($customer.affiliate_percent)}{$customer.affiliate_percent}{else}{$affiliate_percent_default}{/if}" type="number" class="form-control" style="width: 80px;" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
        <div class="kt-portlet kt-portlet--tabs">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Thông tin tài khoản ngân hàng
                    </h3>
                </div>
            </div>

            <div class="kt-portlet__body">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Tên tài khoản
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.bank_name)}
                                        {$customer.bank_name}
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Chủ tài khoản
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.bank_fullname)}
                                        {$customer.bank_fullname}
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label class="col-xl-3 col-lg-4 col-form-label">
                                Số tài khoản
                            </label>

                            <div class="col-lg-8 col-xl-9">
                                <span class="form-control-plaintext kt-font-bolder">
                                    {if !empty($customer.bank_number)}
                                        {$customer.bank_number}
                                    {/if}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
        <div class="kt-portlet kt-portlet--tabs">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Sách và TBYT (Danh sách đơn hàng Affiliate)
                    </h3>
                </div>
            </div>
            
            <div class="kt-portlet__body">
                <div class="kt-section">
                    <div class="kt-section__content" id="products-item-wrap">
                        <table class="table" id="table-items">
                            <thead class="thead-light">
                                <tr>
                                    <th>
                                        Mã đơn hàng
                                    </th>
    
                                    <th>
                                        Ngày đặt
                                    </th>
    
                                    <th>
                                        Tổng tiền đơn hàng
                                    </th>
                                    
                                    <th>
                                        % Hoa hồng
                                    </th>
    
                                    <th>
                                        Hoa hồng
                                    </th>
                                    
                                    <th>
                                        Trạng thái chi trả
                                    </th>
                                </tr>
                            </thead>
    
                            <tbody>
                                {foreach from = $contacts item = item}
                                    <tr>
                                        <td>
                                            <a href="{ADMIN_PATH}/contact/detail/{$item.id}" title="{__d('admin', 'ma_don_hang')}" target="_blank">
                                                <b>
                                                    {if !empty($item.value_decoded.cartId)}
                                                        {$item.value_decoded.cartId}
                                                    {/if}
                                                </b>
                                            </a>
                                        </td>
    
                                        <td>
                                            {if !empty($item.created)}
                                                {date('H:i - d/m/Y', $item.created)}
                                            {/if}
                                        </td>
    
                                        <td>
                                            {if !empty($item.value_decoded.totalPrice)}
                                                {$item.value_decoded.totalPrice|number_format:0:".":","} VNĐ
                                            {/if}
                                        </td>
                                        
                                        <td>
                                            {if !empty($item.value_decoded.affiliatePercent)}
                                                {$item.value_decoded.affiliatePercent|number_format:1:".":","} %
                                            {/if}
                                        </td>
                                        
                                        <td>
                                            {if !empty($item.value_decoded.affiliateAmount)}
                                                {$item.value_decoded.affiliateAmount|number_format:0:".":","} VNĐ
                                            {/if}
                                        </td>
    
                                        <td style="width: 200px">
                                            {if !empty($item.value_decoded.affiliatePaidStatus)}
                                                {if $item.value_decoded.affiliatePaidStatus == "unpaid"}
                                                    <span class="kt-badge  kt-badge--danger kt-badge--inline kt-badge--pill">
                                                        Chưa trả
                                                    </span>
                                                {/if}
                                                
                                                {if $item.value_decoded.affiliatePaidStatus == "paid"}
                                                    <span class="kt-badge  kt-badge--success kt-badge--inline kt-badge--pill">
                                                        Đã trả
                                                    </span>
                                                {/if}
                                            {/if}
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
        <div class="kt-portlet kt-portlet--tabs">
            <div class="kt-portlet__head">
                <div class="kt-portlet__head-label">
                    <h3 class="kt-portlet__head-title">
                        Khóa học (Danh sách đơn hàng Affiliate)
                    </h3>
                </div>
            </div>
            
            <div class="kt-portlet__body">
                <div class="kt-section">
                    <div class="kt-section__content" id="products-item-wrap">
                        <table class="table" id="table-items">
                            <thead class="thead-light">
                                <tr>
                                    <th>
                                        Mã đơn hàng
                                    </th>
    
                                    <th>
                                        Ngày đặt
                                    </th>
    
                                    <th>
                                        Tổng tiền đơn hàng
                                    </th>
                                    
                                    <th>
                                        % Hoa hồng
                                    </th>
    
                                    <th>
                                        Hoa hồng
                                    </th>
                                    
                                    <th>
                                        Trạng thái chi trả
                                    </th>
                                </tr>
                            </thead>
    
                            <tbody>
                                {foreach from = $orders item = item}
                                    <tr>
                                        <td>
                                            <a href="{ADMIN_PATH}/order/detail/{$item.id}" title="{__d('admin', 'ma_don_hang')}" target="_blank">
                                                <b>
                                                    {if !empty($item.code)}
                                                        {$item.code}
                                                    {/if}
                                                </b>
                                            </a>
                                        </td>
    
                                        <td>
                                            {if !empty($item.created)}
                                                {date('H:i - d/m/Y', $item.created)}
                                            {/if}
                                        </td>
    
                                        <td>
                                            {if !empty($item.total)}
                                                {$item.total|number_format:0:".":","} VNĐ
                                            {/if}
                                        </td>
                                        
                                        <td>
                                            {if !empty($item.affiliatePercent)}
                                                {$item.affiliatePercent|number_format:1:".":","} %
                                            {/if}
                                        </td>
                                        
                                        <td>
                                            {if !empty($item.affiliateAmount)}
                                                {$item.affiliateAmount|number_format:0:".":","} VNĐ
                                            {/if}
                                        </td>
    
                                        <td style="width: 200px">
                                            {if !empty($item.affiliatePaidStatus)}
                                                {if $item.affiliatePaidStatus == "unpaid"}
                                                    <span class="kt-badge  kt-badge--danger kt-badge--inline kt-badge--pill">
                                                        Chưa trả
                                                    </span>
                                                {/if}
                                                
                                                {if $item.affiliatePaidStatus == "paid"}
                                                    <span class="kt-badge  kt-badge--success kt-badge--inline kt-badge--pill">
                                                        Đã trả
                                                    </span>
                                                {/if}
                                            {/if}
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
{else}
    <span class="kt-datatable--error">
        {__d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')}
    </span>
{/if}