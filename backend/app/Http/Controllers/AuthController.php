<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'role' => 'user',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Register berhasil',
            'data' => [
                'user' => $user,
                'token' => $user->createToken('frontend-token')->plainTextToken,
            ],
        ], 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        if (($user->is_active ?? true) === false) {
            throw ValidationException::withMessages([
                'email' => ['Akun ini sedang dinonaktifkan oleh admin.'],
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $user->createToken('frontend-token')->plainTextToken,
            ],
        ]);
    }

    public function updateProfile(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'photo_url' => 'nullable|string|max:500',
            'photo' => 'nullable|image|max:2048',
            'favorite_genres' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:30',
            'bio' => 'nullable|string|max:1000',
            'gender' => 'nullable|in:Pria,Wanita,Lainnya',
        ]);

        $user = $request->user();
        unset($data['photo']);

        if ($request->hasFile('photo')) {
            $directory = public_path('uploads/profile-photos');
            if (! is_dir($directory)) {
                mkdir($directory, 0755, true);
            }

            $file = $request->file('photo');
            $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
            $file->move($directory, $filename);
            $data['photo_url'] = asset('uploads/profile-photos/'.$filename);
        }

        $data = collect($data)
            ->filter(fn ($value, $key) => Schema::hasColumn('users', $key))
            ->all();

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => [
                'user' => $user->fresh(),
            ],
        ]);
    }
}
