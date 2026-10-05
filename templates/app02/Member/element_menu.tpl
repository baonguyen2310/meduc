{if !empty($member.avatar)}
    {assign var = avatar value = "{CDN_URL}{$this->Utilities->getThumbs($member.avatar, 350)}"}
{else}
    {assign var = avatar value = "data:image/gif;base64,R0lGODlhAQABAIAAAMLCwgAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="}
{/if}
{assign var = get_path value = "{$this->getRequest()->getPath()}"}
{assign var = plugins value = $this->Setting->getListPlugins()}

{assign var = is_partner_affiliate value = false}
{if !empty($member.is_partner_affiliate) && $member.is_partner_affiliate == 1}
    {$is_partner_affiliate = true}
{/if}
<div class="rounded bg-white p-10 mb-10 h-100">
    <div class="profile-top-left">
        <div class="img-profile text-center mb-10 mt-20">
            <div class="avatar-upload">
                <div class="avatar-edit">
                    <input type="file" name="avatar" nh-avatar-upload id="imageUpload" accept="image/jpeg, image/png" />
                    <label for="imageUpload">{__d('template', 'sua')}</label>
                </div>
                <div class="avatar-preview">
                    <div nh-avatar style="background-image: url({$avatar})"></div>
                </div>
            </div>
        </div>
        <div class="color-black font-weight-bold text-center fs-16 pb-10">
            {if !empty($member.full_name)}
                {$member.full_name}
            {/if}
        </div>
    </div>

    <ul class="member-categories-section member-list list-unstyled mb-0">
        <div class="customer-support font-weight-bold mb-10">
            {__d('template', 'tai_khoan_cua_toi')}
        </div>

        <li class="{if $get_path == '/member/dashboard' || $get_path == '/member/profile'}active{/if}">
            <a href="/member/dashboard" class="color-black">
                <i class="iconsax isax-2x isax-tag-user"></i>
                {__d('template', 'thong_tin_ca_nhan')}
            </a>
        </li>

        <li class="{if ($get_path == '/member/address')}active{/if}">
            <a href="/member/address" class="color-black">
                <i class="iconsax isax-2x isax-buildings"></i>
                {__d('template', 'dia_chi_nhan_hang')}
            </a>
        </li>

        <li class="{if $get_path == '/member/order' || strpos($get_path, '/member/order/detail/') === 0}active{/if}">
            <a href="/member/order" class="color-black">
                <i class="iconsax isax-2x isax-clipboard-text"></i>
                {__d('template', 'don_hang')}
            </a>
        </li>

        {if !empty($plugins.point) || !empty($plugins.affiliate)}
            <div class="customer-support font-weight-bold mb-10">
                {__d('template', 'vi_cua_toi')}
            </div>
        {/if}

        {if !empty($plugins.point)}
            <li class="{if $get_path == '/member/wallet' || $get_path == '/member/money-send' || $get_path == '/member/wallet/buy-point'|| $get_path == '/member/wallet/buy-point-success' || $get_path == '/member/wallet/give-point'}active{/if}">
                <a href="/member/wallet" class="color-black">
                    <i class="iconsax isax-2x isax-wallet-check"></i>
                    {__d('template', 'vi_cua_ban')}
                </a>
            </li>
        {/if}

        {if !empty($plugins.affiliate) && $is_partner_affiliate}
            <li class="{if $get_path == '/member/bank'}active{/if}">
                <a href="/member/bank" class="color-black">
                    <i class="iconsax isax-2x isax-cards"></i>
                    {__d('template', 'tai_khoan_ngan_hang')}
                </a>
            </li>
        {/if}

        {if !empty($plugins.promotion) || !empty($plugins.point)}
            <div class="customer-support font-weight-bold mb-10">
                {__d('template', 'qua_tang')}
            </div>
        {/if}

        {if !empty($plugins.promotion)}
            <li class="{if $get_path == '/member/promotion'}active{/if}">
                <a href="/member/promotion" class="color-black">
                    <i class="iconsax isax-2x isax-ticket"></i>
                    {__d('template', 'phieu_giam_gia')}
                </a>
            </li>
        {/if}

        {if !empty($plugins.point)}
            <li class="{if $get_path == '/member/attendance'}active{/if}">
                <a href="/member/attendance" class="color-black">
                    <i class="iconsax isax-2x isax-menu-board"></i>
                    {__d('template', 'diem_danh_nhan_qua')}
                </a>
            </li>
        {/if}

        {if !empty($plugins.affiliate)}
            <div class="customer-support font-weight-bold mb-10">
                {__d('template', 'tai_khoan_doi_tac')}
            </div>

            {if $is_partner_affiliate}
                <li class="{if $get_path == '/member/affiliate/dashboard'}active{/if}">
                    <a href="/member/affiliate/dashboard" class="color-black">
                        <i class="iconsax isax-2x isax-note-2"></i>
                        {__d('template', 'tong_quan')}
                    </a>
                </li>

                <li class="{if $get_path == '/member/affiliate/order' || strpos($get_path, '/member/affiliate/order-info/') === 0}active{/if}">
                    <a href="/member/affiliate/order" class="color-black">
                        <i class="iconsax isax-2x isax-bookmark-2"></i>
                        {__d('template', 'don_gioi_thieu')}
                    </a>
                </li>

                <li class="{if $get_path == '/member/affiliate/list-point-tomoney'}active{/if}">
                    <a href="/member/affiliate/list-point-tomoney" class="color-black">
                        <i class="iconsax isax-2x isax-card-pos"></i>
                        {__d('template', 'lich_su_rut_tien')}
                    </a>
                </li>
            {else}
                <li class="{if $get_path == '/member/affiliate/active' || $get_path == '/member/affiliate/policy'}active{/if}">
                    <a href="/member/affiliate/policy" class="color-black">
                        <i class="iconsax isax-2x isax-message-question"></i>
                        {__d('template', 'kich_hoat_tai_khoan')}
                    </a>
                </li>
            {/if}
        {/if}

        <li class="btn-logout">
            <a href="/member/logout" class="btn bg-main btn-1a color-white fs-14 px-25 rounded text-center d-block">
                {__d('template', 'dang_xuat')}
            </a>
        </li>
    </ul>
</div>