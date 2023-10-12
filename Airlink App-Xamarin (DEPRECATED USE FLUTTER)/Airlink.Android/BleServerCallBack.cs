using Android.App;
using Android.Bluetooth;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Xamarin.Forms;

namespace Airlink.Droid
{
    public class BleEventArgs : EventArgs
    {
        public BluetoothDevice Device { get; set; }
        public GattStatus GattStatus { get; set; }
        public BluetoothGattCharacteristic Characteristic { get; set; }
        public byte[] Value { get; set; }
        public int RequestId { get; set; }
        public int Offset { get; set; }

        public BluetoothGattDescriptor Descriptor { get; set; }

        public bool PreparedWrite { get; set; }
        public ProfileState NewState { get; set; }
        public bool ResponseNeeded { get; set; }
    }

    public class BleServerCallBack : BluetoothGattServerCallback
    {

        public event EventHandler<BleEventArgs> NotificationSent;
        public event EventHandler<BleEventArgs> CharacteristicReadRequest;
        public event EventHandler<BleEventArgs> DescriptorWriteRequest;
        public event EventHandler<BleEventArgs> CharacteristicWriteRequest;
        public event EventHandler<BleEventArgs> ConnectionStateChange;
        public BleServerCallBack()
        {

        }

        public override void OnCharacteristicReadRequest(
            BluetoothDevice device,
            int requestId,
            int offset,
            BluetoothGattCharacteristic characteristic)
        {
            base.OnCharacteristicReadRequest(device, requestId, offset, characteristic);

            if (CharacteristicReadRequest != null)
            {
                CharacteristicReadRequest(this, new BleEventArgs()
                {
                    Device = device,
                    Characteristic = characteristic,
                    RequestId = requestId,
                    Offset = offset
                });
            }
        }

        public override void OnCharacteristicWriteRequest(
            BluetoothDevice device,
            int requestId,
            BluetoothGattCharacteristic characteristic,
            bool preparedWrite,
            bool responseNeeded,
            int offset,
            byte[] value)
        {
            base.OnCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value);
            if (CharacteristicWriteRequest != null)
            {
                CharacteristicWriteRequest(this, new BleEventArgs()
                {
                    Device = device,
                    ResponseNeeded = responseNeeded,
                    RequestId = requestId,
                    Characteristic = characteristic,
                    PreparedWrite = preparedWrite,
                    Offset = offset,
                    Value = value
                });
            }
        }

        public override void OnConnectionStateChange(BluetoothDevice device, ProfileState status, ProfileState newState)
        {
            base.OnConnectionStateChange(device, status, newState);
            ConnectionStateChange(this, new BleEventArgs() { Device = device, NewState = newState });

        }
        public override void OnDescriptorReadRequest(BluetoothDevice device, int requestId, int offset, BluetoothGattDescriptor descriptor)
        {
            base.OnDescriptorReadRequest(device, requestId, offset, descriptor);
            MessagingCenter.Send<Airlink.App, string>((Airlink.App)Xamarin.Forms.Application.Current, "Hi", "read Value descr: ");
        }
        public override void OnDescriptorWriteRequest(
            BluetoothDevice device,
            int requestId,
            BluetoothGattDescriptor descriptor,
            bool preparedWrite,
            bool responseNeeded,
            int offset,
            byte[] value)
        {
            base.OnDescriptorWriteRequest(device, requestId, descriptor, preparedWrite, responseNeeded, offset, value);
            if (DescriptorWriteRequest != null)
            {
                DescriptorWriteRequest(this, new BleEventArgs()
                {
                    Device = device,
                    RequestId = requestId,
                    Descriptor = descriptor,
                    PreparedWrite = preparedWrite,
                    ResponseNeeded = responseNeeded,
                    Offset = offset,
                    Value = value
                });
            }
        }
        public override void OnExecuteWrite(BluetoothDevice device, int requestId, bool execute)
        {
            base.OnExecuteWrite(device, requestId, execute);
            MessagingCenter.Send<Airlink.App, string>((Airlink.App)Xamarin.Forms.Application.Current, "Hi", "execute write descr: ");
        }
        public override void OnNotificationSent(BluetoothDevice device, GattStatus status)
        {
            base.OnNotificationSent(device, status);

        }

    }
}