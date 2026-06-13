<?php

namespace App\Modules\Settings;

use App\Core\Controller;
use App\Core\Http\Request;

class SettingsController extends Controller
{
    private SettingsService $service;

    public function __construct()
    {
        $this->service = new SettingsService(new SettingsModel());
    }

    // GET /api/v1/settings
    public function show(): void
    {
        $this->success($this->service->get());
    }

    // GET /api/v1/admin/settings
    public function adminShow(): void
    {
        $this->success($this->service->get());
    }

    // PATCH /api/v1/admin/settings
    public function update(Request $request): void
    {
        $data = $request->only([
            'shop_name',
            'shop_slogan',
            'shop_logo',
            'shop_poster',
            'bank_card',
            'bank_owner',
            'payment_method',
            'zarinpal_merchant_id',
            'sms_enabled',
        ]);

        try {
            $settings = $this->service->update($data);
            $this->success($settings, 'تنظیمات فروشگاه بروزرسانی شد');
        } catch (\RuntimeException $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 400);
        }
    }
}
