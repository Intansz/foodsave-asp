<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Mengisi data dummy dari database/seeders/data/dummy.json.
 * Semua akun memakai kata sandi uji: FoodSaveUji2026 (khusus pengembangan lokal).
 */
class FoodSaveSeeder extends Seeder
{
    public function run(): void
    {
        $data = json_decode(
            file_get_contents(database_path('seeders/data/dummy.json')),
            true, 512, JSON_THROW_ON_ERROR
        );

        $now = now();
        $passwordHash = Hash::make('FoodSaveUji2026'); // dihitung sekali, dipakai semua akun

        $this->insert('roles', $data['roles'], $now);
        $this->insert('categories', $data['categories'], $now);

        $this->insert('users', array_map(fn ($u) => $u + [
            'password_hash' => $passwordHash,
            'email_verified_at' => $now,
        ], $data['users']), $now);

        $this->insert('merchants', $data['merchants'], $now);
        $this->insert('merchant_locations', $data['merchant_locations'], $now);

        $this->insert('products', array_map(function ($p) use ($now) {
            $p['pickup_deadline'] = $now->copy()->addHours($p['pickup_hours']);
            unset($p['pickup_hours']);

            return $p;
        }, $data['products']), $now);

        $orderDates = [];
        $orders = array_map(function ($o) use ($now, &$orderDates) {
            $date = $now->copy()->subHours($o['ordered_hours_ago']);
            $orderDates[$o['order_id']] = $date;
            unset($o['ordered_hours_ago']);

            return $o + ['order_date' => $date, 'created_at' => $date, 'updated_at' => $date];
        }, $data['orders']);
        $this->insert('orders', $orders, $now);

        $this->insert('order_items', $data['order_items'], $now);

        $this->insert('reviews', array_map(function ($r) use ($orderDates) {
            $date = $orderDates[$r['order_id']]->copy()->addHours($r['reviewed_hours_after']);
            unset($r['reviewed_hours_after']);

            return $r + ['created_at' => $date, 'updated_at' => $date];
        }, $data['reviews']), $now);
    }

    private function insert(string $table, array $rows, $now): void
    {
        foreach (array_chunk($rows, 100) as $chunk) {
            DB::table($table)->insert(array_map(
                fn ($row) => $row + ['created_at' => $now, 'updated_at' => $now],
                $chunk
            ));
        }
    }
}
