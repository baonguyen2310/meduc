{assign var = order_info value = $this->Order->getInfoOrder($id_record)}

{if !empty($order_info)}
    {assign var = unit value = 'đ'}
    {assign var = contact value = []}
    {if !empty($order_info.contact)}
        {assign var = contact value = $order_info.contact}
    {/if}

    <div style="margin-bottom:10px">
        {if !empty($contact.full_name)}
            <strong>
                Xin chào {$contact.full_name}!
            </strong>
        {/if}
    </div>

    <div style="margin-bottom: 10px">
        Chúc mừng bạn đã đăng ký thành công khoá học tại Trung Tâm Đào Tạo Y Khoa MedUC. Nếu bạn đã hoàn tất thanh toán, hãy nhắn tin tới số Zalo: 0339308997 (Bs: Nghĩa Đức) để được hướng dẫn vào lớp học nhé. Xin chân thành cám ơn.
    </div>
    
    <div style="margin-bottom: 10px">
        Hẹn gặp bạn bên trong khoá học!
    </div>

    <div style="margin-bottom: 10px">
        <strong style="font-size:12px">
            {__d('template', 'thong_tin_khach_hang')}:
        </strong>
    </div>

    <table width="100%" cellspacing="0" cellpadding="0" style="border: 1px solid #F35925; border-top: none; margin-bottom:20px">
        <tbody>
            {if !empty($contact.full_name)}
                <tr>
                    <td width="25%" style="border-top: 1px solid #F35925; border-right: 1px solid #F35925; padding: 10px;">
                        {__d('template', 'ho_va_ten')}
                    </td>
                    <td style="border-top: 1px solid #F35925; padding: 10px;">
                        {$contact.full_name}
                    </td>
                </tr>
            {/if}
            {if !empty($contact.email)}
                <tr>
                    <td style="border-top: 1px solid #F35925; border-right: 1px solid #F35925; padding: 10px;">
                        Email
                    </td>
                    <td style="border-top: 1px solid #F35925; padding: 10px;">
                        {$contact.email}
                    </td>
                </tr>
            {/if}
            {if !empty($contact.phone)}
                <tr>
                    <td style="border-top: 1px solid #F35925; border-right: 1px solid #F35925; padding: 10px;">
                        {__d('template', 'so_dien_thoai')}
                    </td>
                    <td style="border-top: 1px solid #F35925; padding: 10px;">
                        {$contact.phone}
                    </td>
                </tr>
            {/if}
            {if !empty($contact.full_address)}
                <tr>
                    <td style="border-top: 1px solid #F35925; border-right: 1px solid #F35925; padding: 10px;">
                        {__d('template', 'dia_chi')}
                    </td>
                    <td style="border-top: 1px solid #F35925; padding: 10px;">
                        {$contact.full_address}
                    </td>
                </tr>
            {/if}
        </tbody>
    </table>

    {if !empty($order_info.items)}
        <div style="margin-bottom:10px">
            <strong style="font-size:12px">
                {__d('template', 'thong_tin_san_pham')}:
            </strong>
        </div>

        <table width="100%" cellspacing="0" cellpadding="0" style="border: 1px solid #F35925">
            <thead>
                <tr style="background: #F35925; color: #fff;">
                    <th align="left" style="padding: 10px; font-weight: normal;">
                        {__d('template', 'san_pham')}
                    </th>

                    <th align="left" style="padding: 10px; font-weight: normal;">
                        {__d('template', 'don_gia')}
                    </th>

                    <th align="left" style="padding: 10px; font-weight: normal;">
                        {__d('template', 'so_luong')}
                    </th>

                    <th align="right" style="padding: 10px; font-weight: normal;">
                        {__d('template', 'tien')}
                    </th>
                </tr>
            </thead>

            <tbody>
                {foreach from = $order_info.items item = item key = key}
                    <tr>
                        <td style="border-top: 1px solid #F35925; padding: 10px;">
                            {if !empty($item.name_extend)}
                                {$item.name_extend}
                            {/if}
                        </td>

                        <td style="border-top: 1px solid #F35925; padding: 10px;">
                            {if !empty($item.price)}
                                {$item.price|number_format:0:".":","}
                            {else}
                                0
                            {/if}
                        </td>

                        <td style="border-top: 1px solid #F35925; padding: 10px;">
                            {if !empty($item.quantity)}
                                {$item.quantity|number_format:0:".":","}
                            {/if}
                        </td>

                        <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                            {if !empty($item.price) && !empty($item.quantity)}
                                {($item.quantity * $item.price)|number_format:0:".":","}
                            {else}
                                0
                            {/if}
                            {$unit}
                        </td>
                    </tr>
                {/foreach}
            </tbody>

            <tfoot>
                {*<tr>
                    <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                        {__d('template', 'phi_van_chuyen')}
                    </td>
                    
                    <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                        {if !empty($order_info.shipping_fee_customer)}
                            + {$order_info.shipping_fee_customer|number_format:0:".":","}
                        {else}
                            0
                        {/if}
                        {$unit}
                    </td>
                </tr>*}

                {if !empty($order_info.total_coupon)}
                    <tr>
                        <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                            {__d('template', 'phieu_giam_gia')}
                        </td>
                        
                        <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                            - {$order_info.total_coupon|number_format:0:".":","} {$unit}
                        </td>
                    </tr>
                {/if}

                {if !empty($order_info.total_affiliate)}
                    <tr>
                        <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                            {__d('template', 'ma_gioi_thieu')}
                        </td>
                        
                        <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                            - {$order_info.total_affiliate|number_format:0:".":","} {$unit}
                        </td>
                    </tr>
                {/if}

                {if !empty($order_info.total_vat)}
                    <tr>
                        <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                            VAT
                        </td>
                        
                        <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                            + {$order_info.total_vat|number_format:0:".":","} {$unit}
                        </td>
                    </tr>
                {/if}

                <tr>
                    <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                        <strong>
                            {__d('template', 'tong_tien')}
                        </strong>
                    </td>
                    
                    <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                        <strong>
                            {if !empty($order_info.total)}
                                {$order_info.total|number_format:0:".":","}
                            {else}
                                0
                            {/if}
                            {$unit}
                        </strong>
                    </td>
                </tr>
                {if !empty($order_info.point_promotion_paid) || !empty($order_info.point_paid)} 
                    {if !empty($order_info.point_promotion_paid)}
                        <tr>
                            <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                                {__d('template', 'thanh_toan_bang_diem_khuyen_mai')}
                            </td>
                            
                            <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                                -  {$order_info.point_promotion_paid|number_format:0:".":","} {$unit}
                            </td>
                        </tr>
                    {/if}

                    {if !empty($order_info.point_paid)}
                        <tr>
                            <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                                {__d('template', 'thanh_toan_bang_diem_vi')}
                            </td>
                            
                            <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                                - {$order_info.point_paid|number_format:0:".":","} {$unit}
                            </td>
                        </tr>
                    {/if}
                    {if !empty($order_info.debt)}
                        <tr>
                            <td align="right" colspan="3" style="border-top: 1px solid #F35925; padding: 10px;">
                                {__d('template', 'con_phai_thanh_toan')}
                            </td>
                            
                            <td align="right" style="border-top: 1px solid #F35925; padding: 10px;">
                                {$order_info.debt|number_format:0:".":","} {$unit}
                            </td>
                        </tr>
                    {/if}
                {/if}

            </tfoot>
        </table>
    {/if}
{/if}