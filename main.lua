#include <windows.h>
#include <d3d9.h>
#include <iostream>
#include <math.h>

// Hook D3D9 untuk injeksi
LPDIRECT3DDEVICE9 g_pd3dDevice;
struct PlayerData { float x, y, z; int health; bool isEnemy; };

// Fungsi Aimbot & Auto Shoot
void AimbotAndShoot(LONG targetPid, DWORD playerAddress) {
    // Hitbox target: Kepala (Head)
    float targetX = *(float*)(playerAddress + 0x0C0); // Offset X Head
    float targetY = *(float*)(playerAddress + 0x0C4); // Offset Y Head
    float targetZ = *(float*)(playerAddress + 0x0C8); // Offset Z Head

    // Kalkulasi sudut (Yaw dan Pitch) ke target
    float yaw = atan2(targetZ - *(float*)(0x100), targetX - *(float*)(0x104)) * (180.0 / M_PI);
    float pitch = asin((targetY - *(float*)(0x108)) / sqrt(pow(targetX - *(float*)(0x104), 2) + pow(targetY - *(float*)(0x108), 2) + pow(targetZ - *(float*)(0x10C), 2))) * (180.0 / M_PI);

    // Set sudut kamera player
    *(float*)(0x1F0) = yaw; // Offset Yaw Player
    *(float*)(0x1F4) = pitch; // Offset Pitch Player

    // Simulasi klik kiri (Auto Shoot)
    SetFocus();
    InputSimulateMouseClick();
}

// Fungsi Super Speed (Lari Cepat)
void SuperSpeed() {
    // Modifikasi offset kecepatan player
    *(float*)(0x200) = 500.0f; // Kecepatan normal biasanya ~350.0f
}

// Fungsi Invisibility (Invisible)
void Invisibility() {
    // Set material render player menjadi transparan atau non-render
    DWORD renderAddress = *(DWORD*)(0x250); // Offset Material
    *(float*)(renderAddress + 0x10) = 0.0f; // Alpha = 0 (Transparan)
}

// Fungsi High Jump (Lompat Tinggi)
void HighJump() {
    // Modifikasi gravitasi dan kecepatan vertikal
    *(float*)(0x300) = -1500.0f; // Kecepatan vertikal awal
    *(float*)(0x304) = 0.5f; // Gravitasi dikurangi agar melayang lebih lama
}

// Loop Utama Injeksi
void MainLoop() {
    while (true) {
        for (int i = 0; i < 64; i++) { // Loop 64 pemain
            if (*(BOOL*)(playerAddress[i] + 0x10) == true) { // Cek jika hidup
                AimbotAndShoot(GetCurrentProcessId(), playerAddress[i]);
            }
        }
        SuperSpeed();
        Invisibility();
        HighJump();
        Sleep(10); // Loop setiap 10ms
    }
}

int main() {
    // Inisialisasi D3D9 Hook
    InitializeD3D9Hook();
    MainLoop();
    return 0;
}
