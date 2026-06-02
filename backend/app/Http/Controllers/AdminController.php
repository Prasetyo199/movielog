<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    private function ensureAdmin(Request $request)
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Hanya admin yang boleh mengakses fitur ini.');
        }
    }

    public function users(Request $request)
    {
        $this->ensureAdmin($request);

        return response()->json([
            'success' => true,
            'message' => 'Daftar user berhasil diambil',
            'data' => User::latest()->get(),
        ]);
    }

    public function destroyUser(Request $request, User $user)
    {
        $this->ensureAdmin($request);

        if ($request->user()?->id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak bisa menghapus akunnya sendiri',
            ], 422);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dihapus',
        ]);
    }

    public function toggleUserStatus(Request $request, User $user)
    {
        $this->ensureAdmin($request);

        if ($request->user()?->id === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Admin tidak bisa menonaktifkan akunnya sendiri',
            ], 422);
        }

        $data = $request->validate([
            'is_active' => 'required|boolean',
        ]);

        $user->update(['is_active' => $data['is_active']]);

        return response()->json([
            'success' => true,
            'message' => $user->is_active ? 'User diaktifkan' : 'User dinonaktifkan',
            'data' => $user,
        ]);
    }
}
