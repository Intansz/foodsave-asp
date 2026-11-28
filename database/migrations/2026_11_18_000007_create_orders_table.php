<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id('order_id');
            $table->foreignId('user_id')->constrained('users', 'user_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->foreignId('merchant_id')->constrained('merchants', 'merchant_id')->restrictOnDelete()->cascadeOnUpdate();
            $table->string('order_code', 30)->unique();
            $table->dateTime('order_date');
            $table->string('order_status', 30)->default('dipesan');
            $table->decimal('total_amount', 12, 2)->default(0);
            $table->timestamps();

            $table->index('order_status', 'idx_orders_status');
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE orders ADD CONSTRAINT chk_orders_status CHECK (order_status IN ('dipesan','disiapkan','selesai','dibatalkan'))");
            DB::statement('ALTER TABLE orders ADD CONSTRAINT chk_orders_total CHECK (total_amount >= 0)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
