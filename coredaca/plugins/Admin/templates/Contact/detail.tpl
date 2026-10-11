{if !empty($contact)}
    {assign var = url_list value = "{ADMIN_PATH}/contact/list"}

    {if $contact["form_id"] == "6"} 
        <div class="kt-subheader   kt-grid__item" id="kt_subheader">
            <div class="kt-container  kt-container--fluid ">
                <div class="kt-subheader__main">
                    <h3 class="kt-subheader__title">
                        Chi tiết đơn hàng Sách / Thiết bị y tế
                    </h3>
                </div>

                <div class="kt-subheader__toolbar">
                    {if $contact.value.orderStatus != "success"}
                        <button button-update-order data-link="/admin/contact/update/{$contact.id}" data-order-status="success" type="button" class="btn btn-sm btn-brand btn-success">
                            Duyệt đơn Affiliate
                        </button>
                    {/if}
                    {*if $contact.value.orderStatus != "cancel"}
                        <button button-update-order data-link="/admin/contact/update/{$contact.id}" data-order-status="cancel" type="button" class="btn btn-sm btn-brand btn-danger">
                            Hủy đơn
                        </button>
                    {/if*}
                    <a href="{$url_list}?contact={$contact["form_id"]}" class="btn btn-sm btn-default">
                        {__d('admin', 'quay_lai_danh_sach')}
                    </a>
                </div>
            </div>
        </div>

        <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
            <div class="kt-wizard-v4">
                <div class="kt-portlet">
                    <div class="kt-portlet__body kt-portlet__body--fit">
                        <div class="kt-grid">
                            <div class="kt-grid__item kt-grid__item--fluid kt-wizard-v4__wrapper">
                                <div class="kt-form" style="width: 95%">
                                    <div class="kt-wizard-v4__content">
                                        <div class="kt-heading kt-heading--md">
                                            Mã đơn hàng:
                                            {if !empty($contact.value.cartId)}
                                                <strong>
                                                    {$contact.value.cartId}
                                                </strong>                                    
                                            {/if}
                                        </div>

                                        <div class="kt-form__section kt-form__section--first">
                                            <div class="kt-wizard-v4__review entire-detail">
                                                <div class="kt-wizard-v4__review-item">
                                                    <div class="kt-wizard-v4__review-title pb-20 pt-20">
                                                        Thông tin chi tiết
                                                    </div>
                                                    <div class="kt-wizard-v4__review-content">
                                                        {if !empty($contact.value.full_name)}
                                                            <p class="mb-5">Họ tên: <span class="kt-font-bolder">{$contact.value.full_name}</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.phone)}
                                                            <p class="mb-5">Số điện thoại: <span class="kt-font-bolder">{$contact.value.phone}</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.email)}
                                                            <p class="mb-5">Email: <span class="kt-font-bolder">{$contact.value.email}</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.address)}
                                                            <p class="mb-5">Địa chỉ nhận hàng: <span class="kt-font-bolder">{$contact.value.address}</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.payment)}
                                                            <p class="mb-5">
                                                                Phương thức thanh toán:
                                                                {if $contact.value.payment == "cod"}
                                                                    <span class="kt-badge kt-badge--warning kt-font-bold kt-badge--inline kt-badge--pill">
                                                                        Ship COD
                                                                    </span>
                                                                {/if}
                                                                {if $contact.value.payment == "bank"}
                                                                    <span class="kt-badge kt-badge--info kt-font-bold kt-badge--inline kt-badge--pill">
                                                                        Chuyển khoản
                                                                    </span>
                                                                {/if}
                                                            </p>
                                                        {/if}
                                                        {if !empty($contact.value.note)}
                                                            <div class="mb-5">Ghi chú: <span class="kt-font-bolder">{$contact.value.note}</span></div>
                                                        {/if}
                                                        {if !empty($contact.value.totalQuantity)}
                                                            <p class="mb-5">Số lượng: <span class="kt-font-bolder">{$contact.value.totalQuantity}</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.totalPrice)}
                                                            <p class="mb-5">Tạm tính: <span class="kt-font-bolder">{$contact.value.totalPrice|number_format:0:".":","} VND</span></p>
                                                        {/if}
                                                        {if !empty($contact.value.affiliateAmount)}
                                                            <p class="mb-5">
                                                                Hoa hồng: <span class="kt-font-bolder">{$contact.value.affiliateAmount|number_format:0:".":","} VND</span>
                                                                (Mã giới thiệu: <span class="kt-font-bolder">{$contact.value.affiliateCode} - {$contact.value.affiliatePercent}%</span>)
                                                            </p>
                                                        {/if}
                                                        {if !empty($contact.value.totalPrice)}
                                                            {assign var = totalPrice value = $contact.value.totalPrice}
                                                            {if !empty($contact.value.affiliateAmount)}
                                                                {assign var = totalPrice value = $contact.value.totalPrice - $contact.value.affiliateAmount}
                                                            {/if}
                                                            <p class="mb-5">Tổng tiền: <span class="kt-font-bolder">{$totalPrice|number_format:0:".":","} VND</span></p>
                                                        {/if}
                                                        {if !empty($contact.created)}
                                                            <p class="mb-5">Ngày đặt: <span class="kt-font-bolder">{$contact.created}</span></p>
                                                        {/if}
                                                        
                                                        {if !empty($contact.value.orderStatus)}
                                                            <p class="mb-5">
                                                                Trạng thái đơn hàng: 
                                                                {if $contact.value.orderStatus == "initial"}
                                                                    <span class="kt-badge kt-badge--dark kt-font-bold kt-badge--inline kt-badge--pill">
                                                                        Khởi tạo
                                                                    </span>
                                                                {/if}
                                                                {if $contact.value.orderStatus == "success"}
                                                                    <span class="kt-badge kt-badge--success kt-font-bold kt-badge--inline kt-badge--pill">
                                                                        Đã duyệt
                                                                    </span>
                                                                {/if}
                                                                {if $contact.value.orderStatus == "cancel"}
                                                                    <span class="kt-badge kt-badge--danger kt-font-bold kt-badge--inline kt-badge--pill">
                                                                        Đã hủy
                                                                    </span>
                                                                {/if}
                                                            </p>
                                                        {/if}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="kt-form__section kt-form__section--first">
                                            <div class="kt-wizard-v4__review entire-detail">
                                                <div class="kt-wizard-v4__review-item">
                                                    <div class="kt-wizard-v4__review-title pb-20 pt-20">
                                                        Thông tin sản phẩm
                                                    </div>
                                                    <div class="kt-wizard-v4__review-content">
                                                        {if !empty($contact.value.cartProducts)}
                                                            <div class="table-responsive nh-table-responsive">
                                                                <table id="table-products" class="table mb-0 nh-table-item">
                                                                    <thead class="thead-light">
                                                                        <tr>
                                                                            <th class="text-left" style="width: 50px;">
                                                                                STT
                                                                            </th>

                                                                            <th class="text-left">
                                                                                Tên sản phẩm
                                                                            </th>

                                                                            <th style="width: 150px;">
                                                                                Số lượng
                                                                            </th>

                                                                            <th style="width: 180px;">
                                                                                Giá
                                                                            </th>

                                                                            <th class="text-right" style="width: 180px;">
                                                                                Thành tiền
                                                                            </th>
                                                                        </tr>
                                                                    </thead>


                                                                    {assign var = cartProducts value = $contact.value.cartProducts}

                                                                    <tbody>
                                                                        {foreach from = $cartProducts item = product key = key}   
                                                                            <tr>
                                                                                <td>{$key + 1}</td>
                                                                                <td>{$product->name}</td>
                                                                                <td>{$product->quantity}</td>
                                                                                {if $product->price_special > 0}
                                                                                    <td>{$product->price_special|number_format:0:".":","} VND</td>
                                                                                {else}
                                                                                    <td>{$product->price|number_format:0:".":","} VND</td>
                                                                                {/if}
                                                                                <td class="text-right">{$product->total|number_format:0:".":","} VND</td>
                                                                            </tr>
                                                                        {/foreach}
                                                                    </tbody>

                                                                    <tfoot>
                                                                        <tr>
                                                                            <td colspan="3"></td>

                                                                            <td colspan="1">
                                                                                Tạm tính
                                                                            </td>

                                                                            <td colspan="1" class="text-right">
                                                                                {if !empty($contact.value.totalPrice)}
                                                                                    <strong class="text-danger fs-18">{$contact.value.totalPrice|number_format:0:".":","} VND</strong>
                                                                                {/if}
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td colspan="3"></td>

                                                                            <td colspan="1">
                                                                                Hoa hồng
                                                                            </td>

                                                                            <td colspan="1" class="text-right">
                                                                                <strong class="text-danger fs-18">
                                                                                    {if !empty($contact.value.affiliateAmount)}
                                                                                        {$contact.value.affiliateAmount|number_format:0:".":","} VND
                                                                                    {else}
                                                                                        0 VNĐ
                                                                                    {/if}
                                                                                </strong>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td colspan="3"></td>

                                                                            <td colspan="1">
                                                                                Tổng tiền
                                                                            </td>

                                                                            <td colspan="1" class="text-right">
                                                                                {if !empty($totalPrice)}
                                                                                    <strong class="text-danger fs-18">{$totalPrice|number_format:0:".":","} VND</strong>
                                                                                {/if}
                                                                            </td>
                                                                        </tr>
                                                                    </tfoot>
                                                                </table>
                                                            </div>
                                                        {/if}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    {else}
        <div class="kt-subheader   kt-grid__item" id="kt_subheader">
            <div class="kt-container  kt-container--fluid ">
                <div class="kt-subheader__main">
                    <h3 class="kt-subheader__title">
                        {if !empty($title_for_layout)}{$title_for_layout}{/if}
                    </h3>
                </div>

                <div class="kt-subheader__toolbar">
                    <a href="{$url_list}?contact={$contact["form_id"]}" class="btn btn-sm btn-default">
                        {__d('admin', 'quay_lai_danh_sach')}
                    </a>
                </div>
            </div>
        </div>

        <div class="kt-container  kt-container--fluid  kt-grid__item kt-grid__item--fluid">
            <div class="kt-wizard-v4">
                <div class="kt-portlet">
                    <div class="kt-portlet__body kt-portlet__body--fit">
                        <div class="kt-grid">
                            <div class="kt-grid__item kt-grid__item--fluid kt-wizard-v4__wrapper">
                                <div class="kt-form" style="width: 95%">
                                    <div class="kt-wizard-v4__content">
                                        <div class="kt-heading kt-heading--md">
                                            {__d('admin', 'thong_tin_form')}:
                                            {if !empty($contact.form.name)}
                                                <span>
                                                    {$contact.form.name}
                                                </span>                                            
                                            {/if}
                                        </div>

                                        <div class="kt-form__section kt-form__section--first">
                                            <div class="kt-wizard-v4__review entire-detail">
                                                <div class="kt-wizard-v4__review-item">
                                                    <div class="kt-wizard-v4__review-title pb-20 pt-20">
                                                        {__d('admin', 'noi_dung_lien_he')}
                                                    </div>
                                                    <div class="kt-wizard-v4__review-content">    
                                                        {if !empty($contact.value)}  
                                                            {foreach from = $contact.value item = value key = code}       
                                                                <p class="mb-5">
                                                                    {if !empty($fields[$code])}
                                                                        {$fields[$code]}:
                                                                    {else}
                                                                        {$code}:
                                                                    {/if}    
                                                                    <span class="kt-font-bolder">
                                                                        {$value}
                                                                    </span>
                                                                </p>
                                                            {/foreach}
                                                        {/if} 
                                                        <p class="mb-5">
                                                            {__d('admin', 'ngay_nhan')}:  
                                                            <span class="kt-font-bolder">
                                                                {if !empty($contact.created)}
                                                                    <i>{$contact.created}</i>
                                                                {/if}
                                                            </span>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    {/if}
{else}
    <span class="kt-datatable--error">{__d('admin', 'khong_lay_duoc_thong_tin_ban_ghi')}</span>
{/if}

