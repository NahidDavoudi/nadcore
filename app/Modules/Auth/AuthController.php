<?php

namespace App\Modules\Auth;

use App\Core\Controller;
use App\Core\Http\Request;

class AuthController extends Controller
{
    private AuthService $service;

    public function __construct()
    {
        $this->service = new AuthService();
    }

    // POST /api/v1/auth/register
    public function register(Request $request): void
    {
        $data = $request->only(['name', 'phone', 'password']);

        try {
            $result = $this->service->register($data);
            $this->created($result, 'ثبت‌نام با موفقیت انجام شد');
        } catch (\Exception $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 400);
        }
    }

    // POST /api/v1/auth/login
    public function login(Request $request): void
    {
        $phone    = $request->input('phone');
        $password = $request->input('password');

        if (!$phone || !$password) {
            $this->error('شماره تلفن و رمز عبور الزامی است', 422);
        }

        try {
            $result = $this->service->login($phone, $password);
            $this->success($result, 'ورود موفق');
        } catch (\Exception $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 401);
        }
    }

    // POST /api/v1/auth/admin-login
    public function adminLogin(Request $request): void
    {
        $phone    = $request->input('phone');
        $password = $request->input('password');

        if (!$phone || !$password) {
            $this->error('شماره تلفن و رمز عبور الزامی است', 422);
        }

        try {
            $result = $this->service->adminLogin($phone, $password);
            $this->success($result, 'ورود ادمین موفق');
        } catch (\Exception $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 401);
        }
    }

    // GET /api/v1/auth/me
    public function me(Request $request): void
    {
        try {
            $user = $this->service->me($request->userId());
            $this->success($user);
        } catch (\Exception $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 400);
        }
    }

    // POST /api/v1/auth/refresh
    public function refresh(Request $request): void
    {
        try {
            $result = $this->service->refreshToken(
                $request->userId(),
                $request->user()->role ?? 'user'
            );
            $this->success($result, 'توکن تمدید شد');
        } catch (\Exception $e) {
            $this->error($e->getMessage(), $e->getCode() ?: 401);
        }
    }
}