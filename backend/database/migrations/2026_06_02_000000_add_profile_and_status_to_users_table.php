<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('role');
            }

            if (! Schema::hasColumn('users', 'photo_url')) {
                $table->string('photo_url', 500)->nullable()->after('is_active');
            }

            if (! Schema::hasColumn('users', 'favorite_genres')) {
                $table->string('favorite_genres')->nullable()->after('photo_url');
            }

            if (! Schema::hasColumn('users', 'phone')) {
                $table->string('phone', 30)->nullable()->after('favorite_genres');
            }

            if (! Schema::hasColumn('users', 'bio')) {
                $table->text('bio')->nullable()->after('phone');
            }

            if (! Schema::hasColumn('users', 'gender')) {
                $table->string('gender', 20)->nullable()->after('bio');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            foreach (['gender', 'bio', 'phone', 'favorite_genres', 'photo_url', 'is_active'] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
