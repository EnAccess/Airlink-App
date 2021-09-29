using Airlink.ViewModels;
using Android.App;
using Android.Bluetooth;
using Android.Bluetooth.LE;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using Java.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Xamarin.Forms;

namespace Airlink.Droid
{
  public  class BleServer
    {
        private readonly BluetoothManager _bluetoothManager;
        private BluetoothAdapter _bluetoothAdapter;
        private BleServerCallBack _bluettothServerCallback;
        private BluetoothGattServer _bluetoothServer;
        private BluetoothGattCharacteristic _characteristic;
        private BluetoothGattCharacteristic _characteristic2;
        private BleEventArgs et;


        public BleServer(Context ctx)
        {

            _bluetoothManager = (BluetoothManager)ctx.GetSystemService(Context.BluetoothService);
            _bluetoothAdapter = _bluetoothManager.Adapter;

            _bluettothServerCallback = new BleServerCallBack();
            _bluetoothServer = _bluetoothManager.OpenGattServer(ctx, _bluettothServerCallback);
            var service = new BluetoothGattService(UUID.FromString("ffe0ecd2-3d16-4f8d-90de-e89e7fc396a5"),
                GattServiceType.Primary);
            _characteristic = new BluetoothGattCharacteristic(UUID.FromString("d8de624e-140f-4a22-8594-e2216b84a5f2"), GattProperty.Read | GattProperty.Notify | GattProperty.Write, GattPermission.Read | GattPermission.Write);
            _characteristic.AddDescriptor(new BluetoothGattDescriptor(UUID.FromString("28765900-7498-4bd4-aa9e-46c4a4fb7b07"),
                     GattDescriptorPermission.Write | GattDescriptorPermission.Read));

            service.AddCharacteristic(_characteristic);


            _characteristic = new BluetoothGattCharacteristic(UUID.FromString("d8de624e-140f-4a22-8594-e2216b84a5f3"), GattProperty.Read | GattProperty.Notify | GattProperty.Write, GattPermission.Read | GattPermission.Write);
            _characteristic.AddDescriptor(new BluetoothGattDescriptor(UUID.FromString("28765900-7498-4bd4-aa9e-46c4a4fb7b08"),
                    GattDescriptorPermission.Write | GattDescriptorPermission.Read));

            service.AddCharacteristic(_characteristic);
            _bluetoothServer.AddService(service);

            _bluettothServerCallback.CharacteristicReadRequest += _bluettothServerCallback_CharacteristicReadRequest;
            _bluettothServerCallback.DescriptorWriteRequest += _bluettothServerCallback_DescriptorWriteRequest;
            _bluettothServerCallback.CharacteristicWriteRequest += _bluettothServerCallback_CharacteristicWriteRequest;
            _bluettothServerCallback.NotificationSent += _bluettothServerCallback_NotificationSent;
            _bluettothServerCallback.ConnectionStateChange += _bluettothServerCallback_ConnectionStateChange;
            //           MessagingCenter.Send<sslbe.App, string>((sslble.App)Xamarin.Forms.Application.Current, "Hi", "Server created!");
            //           _bluetoothAdapter.SetName("Concungungoc");
            BluetoothLeAdvertiser myBluetoothLeAdvertiser = _bluetoothAdapter.BluetoothLeAdvertiser;
            var builder = new AdvertiseSettings.Builder();
            builder.SetAdvertiseMode(AdvertiseMode.LowLatency);
            builder.SetConnectable(true);
            builder.SetTimeout(0);
            builder.SetTxPowerLevel(AdvertiseTx.PowerHigh);
            AdvertiseData.Builder dataBuilder = new AdvertiseData.Builder();
            dataBuilder.SetIncludeDeviceName(true);
            //dataBuilder.AddServiceUuid(ParcelUuid.FromString("ffe0ecd2-3d16-4f8d-90de-e89e7fc396a5"));
            dataBuilder.SetIncludeTxPowerLevel(true);
            myBluetoothLeAdvertiser.StartAdvertising(builder.Build(), dataBuilder.Build(), new BleAdvertiseCallback());
        }

        public void SetupMesss(BleEventArgs e)
        {
            try
            {
                et = e;
                MessagingCenter.Subscribe<App, string>((App)Xamarin.Forms.Application.Current, "GetValuex", async (sender, arg) =>
                {

                    e.Characteristic.SetValue(arg.ToString());
                    if (e != null)
                        MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", "[Write]: " + arg.ToString());
                    _bluetoothServer.SendResponse(e.Device, e.RequestId, GattStatus.Success, e.Offset, e.Characteristic.GetValue());
                    _bluetoothServer.NotifyCharacteristicChanged(e.Device, e.Characteristic, false);
                });
            }
            catch (Exception ex)
            {
                MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", ex.ToString());
            }
        }
        void _bluettothServerCallback_NotificationSent(object sender, BleEventArgs e)
        {

            MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", "Get Request Read From Client");
            /*
            if (_count == 0)
            {
                _sw = new Stopwatch();
                _sw.Start();
            }

            if (_count < 1000)
            {
                var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                var random = new System.Random();
                var result = new string(
                    Enumerable.Repeat(chars, 20)
                        .Select(s => s[random.Next(s.Length)])
                        .ToArray());
                _characteristic.SetValue(result);
                MessagingCenter.Send<sslbe.App, string>((sslbe.App)Xamarin.Forms.Application.Current, "Hi", result);
                _bluetoothServer.NotifyCharacteristicChanged(e.Device, _characteristic, false);

                _count++;

            }
            else
            {
                _sw.Stop();
                Console.WriteLine("Sent # {0} notifcations. Total kb:{2}. Time {3}(s). Throughput {1} bytes/s", _count,
                    _count * 20.0f / _sw.Elapsed.TotalSeconds, _count * 20 / 1000, _sw.Elapsed.TotalSeconds);
            } */
            //   _characteristic.SetValue("hello");
            //  MessagingCenter.Send<sslbe.App, string>((sslbe.App)Xamarin.Forms.Application.Current, "Hi", "hello");
            //   _bluetoothServer.NotifyCharacteristicChanged(e.Device, _characteristic, false);
        }

        private bool _notificationsStarted = false;

        private int _readRequestCount = 0;
        void _bluettothServerCallback_CharacteristicReadRequest(object sender, BleEventArgs e)
        {

            if (et == null) SetupMesss(e);
            e.Characteristic.SetValue(String.Format("Hello message from server."));
            _bluetoothServer.SendResponse(e.Device, e.RequestId, GattStatus.Success, e.Offset, e.Characteristic.GetValue());
        }
        void _bluettothServerCallback_DescriptorWriteRequest(object sender, BleEventArgs e)
        {
            try
            {
                e.Characteristic.SetValue(String.Format("Thanks for message"));
                string result = Encoding.UTF8.GetString(e.Value);
                MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", "[Read]: " + result);
                if (e.ResponseNeeded) _bluetoothServer.SendResponse(e.Device, e.RequestId, GattStatus.Success, e.Offset, e.Characteristic.GetValue());
            }
            catch (Exception ex)
            {

            }
        }
        void _bluettothServerCallback_CharacteristicWriteRequest(object sender, BleEventArgs e)
        {
            try
            {
                e.Characteristic.SetValue(String.Format("Thanks for message"));
                string result = Encoding.UTF8.GetString(e.Value);
                MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", "[" + e.Device.Address + "/" + e.Device.Name + "]: " + result);
                if (et == null) SetupMesss(e);
                if (e.ResponseNeeded) _bluetoothServer.SendResponse(e.Device, e.RequestId, GattStatus.Success, e.Offset, e.Characteristic.GetValue());
            }
            catch (Exception ex)
            {

            }
        }

        void _bluettothServerCallback_ConnectionStateChange(object sender, BleEventArgs e)
        {
            MessagingCenter.Send((App)Xamarin.Forms.Application.Current, "Hi", "[" + e.NewState.ToString() + " Device]Mac:  " + e.Device.Address.ToString());

        }


    }

    public class BleAdvertiseCallback : AdvertiseCallback
    {
        public override void OnStartFailure(AdvertiseFailure errorCode)
        {
            Console.WriteLine("Adevertise start failure {0}", errorCode);
            base.OnStartFailure(errorCode);
        }
        public BluetoothServerModel SharedContext { get; set; }
        public override void OnStartSuccess(AdvertiseSettings settingsInEffect)
        {
            Xamarin.Forms.MessagingCenter.Send("hahahahah", "eventName");
            Console.WriteLine("Adevertise start success {0}", settingsInEffect.Mode);
            base.OnStartSuccess(settingsInEffect);
        }
    }
}