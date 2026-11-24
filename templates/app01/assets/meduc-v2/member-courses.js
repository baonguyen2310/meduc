(() => {
  const page = document.getElementById('member-courses');
  if (!page || page.dataset.signedIn !== '0') return;

  const loginStatus = page.querySelector('[data-member-courses-login-status]');
  let loading = false;
  window.addEventListener('meduc:authenticated', async () => {
    if (!page.isConnected || loading) return;
    loading = true;
    loginStatus.textContent = 'Đang tải khoá học…';
    loginStatus.hidden = false;
    try {
      const response = await fetch(window.location.href, { credentials: 'same-origin', cache: 'no-store' });
      if (!response.ok) throw new Error('Course list request failed');
      const html = new DOMParser().parseFromString(await response.text(), 'text/html');
      const dashboard = html.querySelector('#member-courses[data-signed-in="1"]');
      if (!dashboard) throw new Error('Signed-in course list missing');
      page.replaceWith(dashboard);
    } catch (_) {
      loginStatus.textContent = 'Đã đăng nhập. Tải lại trang để xem khoá học.';
    } finally {
      loading = false;
    }
  });
})();
