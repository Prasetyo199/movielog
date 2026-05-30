<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@movielog.test'],
            [
                'name' => 'Admin MovieLog',
                'role' => 'admin',
                'password' => Hash::make('password'),
            ],
        );

        User::updateOrCreate(
            ['email' => 'user@movielog.test'],
            [
                'name' => 'User MovieLog',
                'role' => 'user',
                'password' => Hash::make('password'),
            ],
        );
    }
}
