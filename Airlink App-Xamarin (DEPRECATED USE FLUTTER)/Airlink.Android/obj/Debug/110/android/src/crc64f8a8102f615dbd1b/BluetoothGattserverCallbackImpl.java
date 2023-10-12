package crc64f8a8102f615dbd1b;


public class BluetoothGattserverCallbackImpl
	extends android.bluetooth.BluetoothGattServerCallback
	implements
		mono.android.IGCUserPeer
{
/** @hide */
	public static final String __md_methods;
	static {
		__md_methods = 
			"";
		mono.android.Runtime.register ("nexus.protocols.ble.BluetoothGattserverCallbackImpl, ble.net-android21", BluetoothGattserverCallbackImpl.class, __md_methods);
	}


	public BluetoothGattserverCallbackImpl ()
	{
		super ();
		if (getClass () == BluetoothGattserverCallbackImpl.class)
			mono.android.TypeManager.Activate ("nexus.protocols.ble.BluetoothGattserverCallbackImpl, ble.net-android21", "", this, new java.lang.Object[] {  });
	}

	private java.util.ArrayList refList;
	public void monodroidAddReference (java.lang.Object obj)
	{
		if (refList == null)
			refList = new java.util.ArrayList ();
		refList.add (obj);
	}

	public void monodroidClearReferences ()
	{
		if (refList != null)
			refList.clear ();
	}
}
