<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('merchants', function (Blueprint $table) {
            $table->id('merchant_id');
            $table->foreignId('user_id')->unique()->constrained('users', 'user_id')->cascadeOnDelete()->cascadeOnUpdate();
            $table->string('business_name', 120);
            $table->string('verification_status', 20)->default('menunggu');
            $table->timestamps();
        });

        if (DB::getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE merchants ADD CONSTRAINT chk_merchants_verification CHECK (verification_status IN ('menunggu','terverifikasi','ditolak'))");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('merchants');
    }
};
