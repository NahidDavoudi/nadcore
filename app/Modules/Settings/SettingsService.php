<?php

namespace App\Modules\Settings;

class SettingsService
{
    private const PAYMENT_METHODS = ['card_to_card', 'zarinpal', 'both'];

    public function __construct(
        private SettingsModel $settingsModel,
    ) {}

    public function get(): array
    {
        return $this->format($this->settingsModel->getOrCreate());
    }

    public function update(array $data): array
    {
        $settings = $this->settingsModel->getOrCreate();
        $payload  = $this->buildUpdatePayload($data);

        if (empty($payload)) {
            throw new \RuntimeException('هیچ فیلدی برای بروزرسانی ارسال نشد.', 422);
        }

        $this->settingsModel->update($settings['id'], $payload);

        return $this->format($this->settingsModel->find($settings['id']));
    }

    private function buildUpdatePayload(array $data): array
    {
        $payload = [];

        foreach (['shop_name', 'shop_slogan', 'shop_logo', 'shop_poster', 'bank_card', 'bank_owner', 'zarinpal_merchant_id'] as $field) {
            if (array_key_exists($field, $data)) {
                $value = $data[$field];
                $payload[$field] = $value === null || $value === '' ? null : trim((string) $value);
            }
        }

        if (array_key_exists('payment_method', $data)) {
            $method = $data['payment_method'];
            if (!in_array($method, self::PAYMENT_METHODS, true)) {
                throw new \RuntimeException('روش پرداخت باید card_to_card، zarinpal یا both باشد.', 422);
            }
            $payload['payment_method'] = $method;
        }

        if (array_key_exists('sms_enabled', $data)) {
            $payload['sms_enabled'] = filter_var($data['sms_enabled'], FILTER_VALIDATE_BOOLEAN) ? 1 : 0;
        }

        return $payload;
    }

    private function format(array $settings): array
    {
        return [
            'shop_name'            => $settings['shop_name'],
            'shop_slogan'          => $settings['shop_slogan'],
            'shop_logo'            => $settings['shop_logo'],
            'shop_poster'          => $settings['shop_poster'],
            'bank_card'            => $settings['bank_card'],
            'bank_owner'           => $settings['bank_owner'],
            'payment_method'       => $settings['payment_method'],
            'zarinpal_merchant_id' => $settings['zarinpal_merchant_id'],
            'sms_enabled'          => (bool) $settings['sms_enabled'],
        ];
    }
}
