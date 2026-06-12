/**
 * api.js — Ghulbazar API Client
 * پوشش کامل تمام endpoint های بک‌اند
 * Pattern: IIFE → window.Api
 */

const Api = (() => {

  // ─── Config ────────────────────────────────────────────────────────────────

  

  // ─── Token Helpers ─────────────────────────────────────────────────────────

  const token = {
    get:    ()        => localStorage.getItem(TOKEN_KEY),
    set:    (t)       => localStorage.setItem(TOKEN_KEY, t),
    remove: ()        => localStorage.removeItem(TOKEN_KEY),
  };

  const role = {
    get:    ()        => localStorage.getItem(ROLE_KEY),
    set:    (r)       => localStorage.setItem(ROLE_KEY, r),
    remove: ()        => localStorage.removeItem(ROLE_KEY),
    isAdmin:()        => localStorage.getItem(ROLE_KEY) === 'admin',
  };

  // ─── HTTP Core ─────────────────────────────────────────────────────────────

  /**
   * @param {string} method
   * @param {string} path
   * @param {Object|FormData|null} body
   * @param {Object} queryParams
   * @returns {Promise<any>}  — همیشه data بر‌می‌گردونه، در error پرتاب می‌کنه
   */
  async function request(method, path, body = null, queryParams = {}) {
    const url = new URL(BASE_URL + path, window.location.origin);

    Object.entries(queryParams).forEach(([k, v]) => {
      if (v !== null && v !== undefined && v !== '') {
        url.searchParams.set(k, v);
      }
    });

    const headers = {};
    const t = token.get();
    if (t) headers['Authorization'] = `Bearer ${t}`;

    const isFormData = body instanceof FormData;
    if (body && !isFormData) headers['Content-Type'] = 'application/json';

    const options = {
      method,
      headers,
      body: body ? (isFormData ? body : JSON.stringify(body)) : null,
    };

    let res = await fetch(url.toString(), options);

    // ── Auto-refresh روی 401 ─────────────────────────────────────────────────
    if (res.status === 401 && t) {
      const refreshed = await _tryRefresh();
      if (refreshed) {
        headers['Authorization'] = `Bearer ${token.get()}`;
        res = await fetch(url.toString(), { ...options, headers });
      }
    }

    // ── 204 No Content ───────────────────────────────────────────────────────
    if (res.status === 204) return null;

    const json = await res.json();

    if (!res.ok) {
      const err = new Error(json?.message || `HTTP ${res.status}`);
      err.status = res.status;
      err.data   = json;
      throw err;
    }

    // بک‌اند همیشه { success, message, data } برمی‌گردونه
    return json?.data !== undefined ? json.data : json;
  }

  async function _tryRefresh() {
    try {
      const res = await fetch(`${BASE_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token.get()}` },
      });
      if (!res.ok) { _logout(); return false; }
      const json = await res.json();
      const newToken = json?.data?.token || json?.data?.access_token;
      if (newToken) { token.set(newToken); return true; }
      _logout(); return false;
    } catch {
      _logout(); return false;
    }
  }

  function _logout() {
    token.remove();
    role.remove();
  }

  // شورتکات‌ها
  const get    = (path, q)    => request('GET',    path, null, q);
  const post   = (path, body) => request('POST',   path, body);
  const put    = (path, body) => request('PUT',    path, body);
  const patch  = (path, body) => request('PATCH',  path, body);
  const del    = (path)       => request('DELETE', path);
  const upload = (path, form) => request('POST',   path, form);  // FormData


  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════════════

  const auth = {

    /** ثبت‌نام — { name, phone, password } */
    register: (data) => post('/auth/register', data),

    /** ورود کاربر — { phone, password } → ذخیره توکن */
    login: async (phone, password) => {
      const data = await post('/auth/login', { phone, password });
      if (data?.token) { token.set(data.token); role.set(data.role || 'user'); }
      return data;
    },

    /** ورود ادمین — { phone, password } → ذخیره توکن + role=admin */
    adminLogin: async (phone, password) => {
      const data = await post('/auth/admin-login', { phone, password });
      if (data?.token) { token.set(data.token); role.set('admin'); }
      return data;
    },

    /** اطلاعات کاربر جاری */
    me: () => get('/auth/me'),

    /** تمدید توکن */
    refresh: () => post('/auth/refresh'),

    /** خروج — فقط local */
    logout: () => _logout(),

    /** آیا لاگین هست؟ */
    isLoggedIn: () => !!token.get(),

    /** آیا ادمین هست؟ */
    isAdmin: () => role.isAdmin(),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // USERS (پروفایل + آدرس + مدیریت ادمین)
  // ═══════════════════════════════════════════════════════════════════════════

  const users = {

    // ─── پروفایل ──────────────────────────────────────────────────────────────
    /** پروفایل کاربر جاری */
    getProfile: () => get('/users/me'),

    /** ویرایش پروفایل — { name?, email? } */
    updateProfile: (data) => patch('/users/me', data),

    /** تغییر رمز عبور — { current_password, new_password } */
    changePassword: (currentPassword, newPassword) =>
      put('/users/me/password', { current_password: currentPassword, new_password: newPassword }),

    // ─── آدرس‌ها ──────────────────────────────────────────────────────────────
    /** لیست آدرس‌های کاربر */
    getAddresses: () => get('/users/me/addresses'),

    /** افزودن آدرس — { address, city, state, zip_code } */
    addAddress: (data) => post('/users/me/addresses', data),

    /** ویرایش آدرس */
    updateAddress: (id, data) => patch(`/users/me/addresses/${id}`, data),

    /** حذف آدرس */
    deleteAddress: (id) => del(`/users/me/addresses/${id}`),

    // ─── ادمین ────────────────────────────────────────────────────────────────
    /** لیست همه کاربران (ادمین) */
    all: () => get('/admin/users'),

    /** فعال‌سازی کاربر (ادمین) */
    activate: (id) => patch(`/admin/users/${id}/activate`),

    /** غیرفعال‌سازی کاربر (ادمین) */
    deactivate: (id) => patch(`/admin/users/${id}/deactivate`),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════════

  const products = {

    /**
     * لیست محصولات با فیلتر
     * @param {Object} filters — { category_id?, category?, era?, featured?, q?, sort?, page?, limit? }
     */
    list: (filters = {}) => get('/products', filters),

    /** محصولات ویژه */
    featured: (limit = 8) => get('/products/featured', { limit }),

    /** جزئیات یک محصول */
    get: (id) => get(`/products/${id}`),

    // ─── ادمین ────────────────────────────────────────────────────────────────
    /**
     * ایجاد محصول (ادمین)
     * { name, description, price, category_id, era?, material?, badge?, stock, featured?, is_active? }
     */
    create: (data) => post('/admin/products', data),

    /** ویرایش محصول (ادمین) */
    update: (id, data) => put(`/admin/products/${id}`, data),

    /** حذف محصول (ادمین) */
    delete: (id) => del(`/admin/products/${id}`),

    /** toggle فعال/غیرفعال (ادمین) */
    toggle: (id) => patch(`/admin/products/${id}/toggle`),

    // ─── تصاویر (ادمین) ──────────────────────────────────────────────────────
    /**
     * افزودن تصویر به محصول (ادمین)
     * @param {number} id
     * @param {File} file — فایل تصویر
     * @param {Object} meta — { alt_text?, is_main?, sort_order? }
     */
    addImage: (id, file, meta = {}) => {
      const form = new FormData();
      form.append('image', file);
      if (meta.alt_text  !== undefined) form.append('alt_text',   meta.alt_text);
      if (meta.is_main   !== undefined) form.append('is_main',    meta.is_main);
      if (meta.sort_order !== undefined) form.append('sort_order', meta.sort_order);
      return upload(`/admin/products/${id}/images`, form);
    },

    /** تنظیم تصویر اصلی (ادمین) */
    setMainImage: (id, imageId) => patch(`/admin/products/${id}/images/${imageId}`),

    /** حذف تصویر (ادمین) */
    deleteImage: (id, imageId) => del(`/admin/products/${id}/images/${imageId}`),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  const categories = {

    /** لیست همه دسته‌بندی‌ها */
    list: () => get('/categories'),

    /** جزئیات یک دسته‌بندی */
    get: (id) => get(`/categories/${id}`),

    /** دسته‌بندی با slug */
    bySlug: (slug) => get(`/categories/slug/${slug}`),

    // ─── ادمین ────────────────────────────────────────────────────────────────
    /** ایجاد دسته‌بندی — { name, slug, description?, poster_image? } */
    create: (data) => post('/admin/categories', data),

    /** ویرایش دسته‌بندی */
    update: (id, data) => put(`/admin/categories/${id}`, data),

    /** حذف دسته‌بندی */
    delete: (id) => del(`/admin/categories/${id}`),

    /**
     * آپلود پوستر دسته‌بندی (ادمین)
     * @param {number} id
     * @param {File} file
     */
    uploadPoster: (id, file) => {
      const form = new FormData();
      form.append('poster', file);
      return upload(`/admin/categories/${id}/poster`, form);
    },

    // ─── تصاویر دسته‌بندی (ادمین) ────────────────────────────────────────────
    /** لیست تصاویر */
    getImages: (id) => get(`/admin/categories/${id}/images`),

    /** افزودن تصویر */
    addImage: (id, file, meta = {}) => {
      const form = new FormData();
      form.append('image', file);
      if (meta.alt_text   !== undefined) form.append('alt_text',   meta.alt_text);
      if (meta.is_main    !== undefined) form.append('is_main',    meta.is_main);
      if (meta.sort_order !== undefined) form.append('sort_order', meta.sort_order);
      return upload(`/admin/categories/${id}/images`, form);
    },

    /** تنظیم تصویر اصلی */
    setMainImage: (id, imageId) => patch(`/admin/categories/${id}/images/${imageId}`),

    /** حذف تصویر */
    deleteImage: (id, imageId) => del(`/admin/categories/${id}/images/${imageId}`),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // CART
  // ═══════════════════════════════════════════════════════════════════════════

  const cart = {

    /** محتوای سبد خرید */
    get: () => get('/cart'),

    /** افزودن آیتم — { product_id, qty? } */
    add: (productId, qty = 1) => post('/cart/items', { product_id: productId, qty }),

    /** به‌روزرسانی تعداد آیتم */
    update: (productId, qty) => patch(`/cart/items/${productId}`, { qty }),

    /** حذف آیتم از سبد */
    remove: (productId) => del(`/cart/items/${productId}`),

    /** خالی کردن کل سبد */
    clear: () => del('/cart'),

    /** اعمال کد تخفیف روی سبد — { code } */
    applyDiscount: (code) => post('/cart/discount', { code }),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════════════════════════════

  const orders = {

    /**
     * ثبت سفارش
     * { customer_name, customer_email, customer_phone, shipping_address,
     *   payment_method, discount_code?, notes? }
     */
    place: (data) => post('/orders', data),

    /** لیست سفارش‌های کاربر جاری */
    list: () => get('/orders'),

    /** جزئیات سفارش */
    get: (id) => get(`/orders/${id}`),

    /** جزئیات سفارش با شماره */
    byNumber: (number) => get(`/orders/number/${number}`),

    /** لغو سفارش */
    cancel: (id) => patch(`/orders/${id}/cancel`),

    /**
     * آپلود رسید پرداخت
     * @param {number} id
     * @param {File} file — JPG / PNG / WebP / PDF
     */
    uploadReceipt: (id, file) => {
      const form = new FormData();
      form.append('receipt', file);
      return upload(`/orders/${id}/receipt`, form);
    },

    // ─── ادمین ────────────────────────────────────────────────────────────────
    /**
     * لیست همه سفارش‌ها (ادمین)
     * @param {Object} params — { page?, limit?, status? }
     */
    adminList: (params = {}) => get('/admin/orders', params),

    /** تغییر وضعیت سفارش (ادمین) — status: pending|paid|processing|shipped|delivered|cancelled */
    updateStatus: (id, status) => patch(`/admin/orders/${id}/status`, { status }),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // DISCOUNTS
  // ═══════════════════════════════════════════════════════════════════════════

  const discounts = {

    /**
     * اعتبارسنجی کد تخفیف (عمومی)
     * @param {string} code
     * @param {number} total — مبلغ سبد به ریال
     */
    validate: (code, total) => get('/discounts/validate', { code, total }),

    // ─── ادمین ────────────────────────────────────────────────────────────────
    /** لیست همه کدهای تخفیف */
    list: () => get('/admin/discounts'),

    /** لیست کدهای فعال */
    active: () => get('/admin/discounts/active'),

    /**
     * ایجاد کد تخفیف
     * { code, type: 'percent'|'fixed', value, valid_from, valid_to, is_active? }
     */
    create: (data) => post('/admin/discounts', data),

    /** ویرایش کد تخفیف */
    update: (id, data) => put(`/admin/discounts/${id}`, data),

    /** غیرفعال‌سازی */
    deactivate: (id) => patch(`/admin/discounts/${id}/deactivate`),

    /** حذف */
    delete: (id) => del(`/admin/discounts/${id}`),
  };


  // ═══════════════════════════════════════════════════════════════════════════
  // ADMIN DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════════

  const dashboard = {

    /** آمار کلی داشبورد */
    overview: () => get('/admin/dashboard'),

    /** آمار عددی — total_orders, total_revenue, total_products, total_users */
    stats: () => get('/admin/dashboard/stats'),

    /** سفارش‌های اخیر */
    recentOrders: (limit = 10) => get('/admin/dashboard/orders/recent', { limit }),

    /** توزیع سفارش‌ها بر اساس وضعیت */
    ordersByStatus: () => get('/admin/dashboard/orders/by-status'),

    /** محصولات کم‌موجود */
    lowStock: (threshold = 5) => get('/admin/dashboard/products/low-stock', { threshold }),

    /** پرفروش‌ترین محصولات */
    topProducts: (limit = 10) => get('/admin/dashboard/products/top', { limit }),

    /**
     * درآمد روزانه
     * @param {number} days — بازه به روز (پیش‌فرض ۷)
     */
    revenue: (days = 7) => get('/admin/dashboard/revenue', { days }),
  };


  // ─── Public API ────────────────────────────────────────────────────────────

  return {
    auth,
    users,
    products,
    categories,
    cart,
    orders,
    discounts,
    dashboard,

    // دسترسی مستقیم به توکن در صورت نیاز
    token,
    role,
  };

})();
