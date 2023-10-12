package crc64166363f07a4b3e3f;


public class _IB
	extends android.bluetooth.le.AdvertiseCallback
	implements
		mono.android.IGCUserPeer
{
/** @hide */
	public static final String __md_methods;
	static {
		__md_methods = 
			"";
		mono.android.Runtime.register ("_IB, ble.net-android21", _IB.class, __md_methods);
	}


	public _IB ()
	{
		super ();
		if (getClass () == _IB.class)
			mono.android.TypeManager.Activate ("_IB, ble.net-android21", "", this, new java.lang.Object[] {  });
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
