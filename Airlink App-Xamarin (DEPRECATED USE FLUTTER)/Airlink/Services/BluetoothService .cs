using Android.Bluetooth;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace Airlink.Services
{
    public class BluetoothService : IBluetoothService
    {
        public void OpenBluetooth()
        {
            //turn on bluetooth
            BluetoothAdapter adapter = BluetoothAdapter.DefaultAdapter;
            adapter.Enable();
        }
    }
}
