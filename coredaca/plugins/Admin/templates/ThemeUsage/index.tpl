<div class="kt-container kt-container--fluid kt-grid__item kt-grid__item--fluid mt-4">
  {$this->element('../Dashboard/theme_usage')}
  <section class="kt-portlet">
    <div class="kt-portlet__head"><div class="kt-portlet__head-label"><h3 class="kt-portlet__head-title">Lựa chọn và lịch sử giao diện</h3></div></div>
    <div class="kt-portlet__body">
      <nav class="nav nav-pills mb-4" aria-label="Dữ liệu giao diện">
        <a class="nav-link {if $view == 'history'}active{/if}" href="?view=history">Lịch sử thay đổi</a>
        <a class="nav-link {if $view == 'users'}active{/if}" href="?view=users">Theo tài khoản</a>
        <a class="nav-link {if $view == 'browsers'}active{/if}" href="?view=browsers">Theo trình duyệt</a>
      </nav>
      <form method="get" class="row align-items-end mb-4">
        <input type="hidden" name="view" value="{$view|escape}">
        <div class="col-md-4 mb-3"><label for="theme-q">Tên, email, mã học viên hoặc mã trình duyệt</label><input class="form-control" id="theme-q" name="q" value="{$q|escape}" maxlength="150"></div>
        <div class="col-md-2 mb-3"><label for="theme-filter">Giao diện</label><select id="theme-filter" name="theme" class="form-control"><option value="all">Tất cả</option><option value="light" {if $theme == 'light'}selected{/if}>Sáng</option><option value="dark" {if $theme == 'dark'}selected{/if}>Tối</option></select></div>
        {if $view == 'history'}<div class="col-md-3 mb-3"><label for="theme-reason">Loại thay đổi</label><select class="form-control" id="theme-reason" name="reason"><option value="all">Tất cả</option>{foreach from=$reasons key=key item=label}<option value="{$key|escape}" {if $reason == $key}selected{/if}>{$label|escape}</option>{/foreach}</select></div>{/if}
        {if $customer}<input type="hidden" name="customer" value="{$customer}">{/if}{if $browser}<input type="hidden" name="browser" value="{$browser|escape}">{/if}
        <div class="col-md-3 mb-3"><button class="btn btn-primary" type="submit">Lọc</button><a class="btn btn-outline-secondary ml-2" href="?view={$view|escape}">Bỏ lọc</a></div>
      </form>
      <p class="text-muted">Lịch sử phân biệt lần tự đổi giao diện với lần đặt lại hoặc đồng bộ. Mã trình duyệt là mã nhận diện trên website, không phải tên thiết bị. Dữ liệu lịch sử bắt đầu từ khi cập nhật tính năng.</p>
      {if $customer || $browser}<p class="alert alert-light border">Đang lọc {if $customer}tài khoản #{$customer}{/if} {if $browser}· trình duyệt {$browser|escape}{/if}.</p>{/if}
      <div class="table-responsive"><table class="table table-bordered table-hover">
        <thead><tr><th>{if $view == 'history'}Thời gian{else}Cập nhật gần nhất{/if}</th><th>Học viên</th>{if $view != 'users'}<th>Trình duyệt</th>{/if}{if $view == 'history'}<th>Trước → Sau trên trình duyệt</th><th>Thay đổi theo tài khoản</th><th>Loại thay đổi</th>{else}<th>Lựa chọn hiện tại</th><th>Lịch sử</th>{/if}</tr></thead>
        <tbody>
        {foreach from=$rows item=row}
          <tr>
            <td style="white-space:nowrap">{if $view == 'history'}{$row.created|date_format:'%d/%m/%Y %H:%M:%S'}{else}{$row.last_seen|date_format:'%d/%m/%Y %H:%M:%S'}{/if}</td>
            <td>{if $row.customer_id}<a href="?view=history&amp;customer={$row.customer_id}"><strong>{$row.full_name|default:'Học viên'|escape}</strong></a><br>{$row.customer_code|escape}<br><span class="text-muted">{$row.email|escape}</span>{else}<span class="text-muted">Khách chưa đăng nhập</span>{/if}</td>
            {if $view != 'users'}<td><a href="?view=history&amp;browser={$row.browser_key|escape}"><code>{$row.browser_label|escape}</code></a></td>{/if}
            {if $view == 'history'}
              <td>{if $row.previous_theme == 'dark'}Tối{elseif $row.previous_theme == 'light'}Sáng{else}Chưa ghi nhận{/if} → <strong>{if $row.theme == 'dark'}Tối{else}Sáng{/if}</strong></td>
              <td>{if $row.customer_id}{if $row.customer_previous_theme == 'dark'}Tối{elseif $row.customer_previous_theme == 'light'}Sáng{else}Chưa ghi nhận{/if} → {if $row.theme == 'dark'}Tối{else}Sáng{/if}{else}—{/if}</td>
              <td>{$reasons[$row.reason]|default:$row.reason|escape}</td>
            {else}
              <td>{if !$row.current}<span class="badge badge-warning">Chờ áp dụng mặc định sáng khi quay lại</span>{elseif $row.theme == 'dark'}<span class="badge badge-dark">Tối</span>{else}<span class="badge badge-light border">Sáng</span>{/if}</td>
              <td><a href="?view=history{if $view == 'users'}&amp;customer={$row.customer_id}{else}&amp;browser={$row.browser_key|escape}{/if}">Xem lịch sử</a></td>
            {/if}
          </tr>
        {foreachelse}<tr><td colspan="6" class="text-center text-muted py-5">Chưa có dữ liệu phù hợp.</td></tr>{/foreach}
        </tbody>
      </table></div>
      <div class="d-flex justify-content-between align-items-center mt-3"><span>{$total} bản ghi · Trang {$page}/{$pages}</span><div>{if $page > 1}<a class="btn btn-outline-secondary mr-2" href="{$previous_url|escape}">Trước</a>{/if}{if $page < $pages}<a class="btn btn-outline-secondary" href="{$next_url|escape}">Sau</a>{/if}</div></div>
    </div>
  </section>
</div>
