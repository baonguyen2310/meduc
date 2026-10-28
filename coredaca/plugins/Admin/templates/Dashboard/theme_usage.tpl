<section class="kt-portlet" aria-labelledby="theme-usage-title">
  <div class="kt-portlet__head"><div class="kt-portlet__head-label"><h3 class="kt-portlet__head-title" id="theme-usage-title">Thống kê giao diện sáng / tối</h3></div></div>
  <div class="kt-portlet__body">
    {if empty($theme_usage.installed)}
      <p class="mb-0 text-muted">Thống kê giao diện đang được cập nhật.</p>
    {else}
      <p class="text-muted mb-4">Tổng cộng <strong class="text-dark">{$theme_usage.total|number_format:0:',':'.'} người</strong> được ghi nhận · Mỗi người được tính theo giao diện sử dụng gần nhất.</p>
      <div class="row">
        <div class="col-md-6 mb-3">
          <div class="rounded p-4 h-100" style="background:#1b1d25;color:#fff">
            <div class="d-flex justify-content-between align-items-center mb-3"><span style="font-size:1.2rem;font-weight:600"><i class="fas fa-moon mr-2" aria-hidden="true"></i>Giao diện tối</span><span>{$theme_usage.dark.percent|number_format:1:',':'.'}%</span></div>
            <div style="font-size:2.6rem;font-weight:700;line-height:1.2" aria-label="Số người dùng giao diện tối">{$theme_usage.dark.total|number_format:0:',':'.'}</div>
            <div class="mt-3" style="color:#c7cad3">{$theme_usage.dark.customers|number_format:0:',':'.'} tài khoản · {$theme_usage.dark.browsers|number_format:0:',':'.'} khách theo trình duyệt</div>
          </div>
        </div>
        <div class="col-md-6 mb-3">
          <div class="rounded p-4 h-100" style="background:#f5f5f7;color:#20222a;border:1px solid #e4e5eb">
            <div class="d-flex justify-content-between align-items-center mb-3"><span style="font-size:1.2rem;font-weight:600"><i class="fas fa-sun mr-2" aria-hidden="true"></i>Giao diện sáng</span><span>{$theme_usage.light.percent|number_format:1:',':'.'}%</span></div>
            <div style="font-size:2.6rem;font-weight:700;line-height:1.2" aria-label="Số người dùng giao diện sáng">{$theme_usage.light.total|number_format:0:',':'.'}</div>
            <div class="mt-3 text-muted">{$theme_usage.light.customers|number_format:0:',':'.'} tài khoản · {$theme_usage.light.browsers|number_format:0:',':'.'} khách theo trình duyệt</div>
          </div>
        </div>
      </div>
      <p class="text-muted mb-0">Khách được tính theo trình duyệt; khi đăng nhập, lượt khách được gộp vào tài khoản. Một tài khoản trên nhiều thiết bị chỉ tính một lần. Số liệu bắt đầu từ khi bật tính năng, không khôi phục được dữ liệu trước đó.</p>
    {/if}
  </div>
</section>
