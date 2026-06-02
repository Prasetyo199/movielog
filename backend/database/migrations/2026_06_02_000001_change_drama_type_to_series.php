<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE reviews_tabel MODIFY type ENUM('film', 'drama', 'series') NOT NULL");
        DB::statement("ALTER TABLE movies MODIFY type ENUM('film', 'drama', 'series') NOT NULL");
        DB::table('reviews_tabel')->where('type', 'drama')->update(['type' => 'series']);
        DB::table('movies')->where('type', 'drama')->update(['type' => 'series']);
        DB::statement("ALTER TABLE reviews_tabel MODIFY type ENUM('film', 'series') NOT NULL");
        DB::statement("ALTER TABLE movies MODIFY type ENUM('film', 'series') NOT NULL");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE reviews_tabel MODIFY type ENUM('film', 'drama', 'series') NOT NULL");
        DB::statement("ALTER TABLE movies MODIFY type ENUM('film', 'drama', 'series') NOT NULL");
        DB::table('reviews_tabel')->where('type', 'series')->update(['type' => 'drama']);
        DB::table('movies')->where('type', 'series')->update(['type' => 'drama']);
        DB::statement("ALTER TABLE reviews_tabel MODIFY type ENUM('film', 'drama') NOT NULL");
        DB::statement("ALTER TABLE movies MODIFY type ENUM('film', 'drama') NOT NULL");
    }
};
