<?php

namespace App\Modules\Settings;

use App\Core\Database\Model;

class SettingsModel extends Model
{
    protected string $table = 'shop_settings';
    protected bool $timestamps = true;
    protected array $fillable = [
        'shop_name',
        'shop_slogan',
        'shop_logo',
        'shop_poster',
        'bank_card',
        'bank_owner',
        'payment_method',
        'zarinpal_merchant_id',
        'sms_enabled',
    ];

    public function get(): ?array
    {
        $stmt = $this->pdo->query("
            SELECT * FROM {$this->table}
            ORDER BY {$this->primaryKey} ASC
            LIMIT 1
        ");
        $result = $stmt->fetch();
        return $result ?: null;
    }

    public function getOrCreate(): array
    {
        $settings = $this->get();

        if ($settings) {
            return $settings;
        }

        $id = $this->create([
            'shop_name'            => 'فروشگاه',
            'shop_slogan'          => null,
            'shop_logo'            => null,
            'shop_poster'          => null,
            'bank_card'            => null,
            'bank_owner'           => null,
            'payment_method'       => 'card_to_card',
            'zarinpal_merchant_id' => null,
            'sms_enabled'          => 0,
        ]);

        return $this->find($id);
    }
}
