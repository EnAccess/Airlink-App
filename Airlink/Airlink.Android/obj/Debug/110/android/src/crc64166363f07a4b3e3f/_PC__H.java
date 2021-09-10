package crc64166363f07a4b3e3f;


public class _PC__H
	extends android.bluetooth.le.ScanCallback
	implements
		mono.android.IGCUserPeer
{
/** @hide */
	public static final String __md_methods;
	static {
		__md_methods = 
			"n_onBatchScanResults:(Ljava/util/List;)V:GetOnBatchScanResults_Ljava_util_List_Handler\n" +
			"n_onScanFailed:(I)V:GetOnScanFailed_IHandler\n" +
			"n_onScanResult:(ILandroid/bluetooth/le/ScanResult;)V:GetOnScanResult_ILandroid_bluetooth_le_ScanResult_Handler\n" +
			"";
		mono.android.Runtime.register ("_PC+_H, ble.net-android21", _PC__H.class, __md_methods);
	}


	public _PC__H ()
	{
		super ();
		if (getClass () == _PC__H.class)
			mono.android.TypeManager.Activate ("_PC+_H, ble.net-android21", "", this, new java.lang.Object[] {  });
	}


	public void onBatchScanResults (java.util.List p0)
	{
		n_onBatchScanResults (p0);
	}

	private native void n_onBatchScanResults (java.util.List p0);


	public void onScanFailed (int p0)
	{
		n_onScanFailed (p0);
	}

	private native void n_onScanFailed (int p0);


	public void onScanResult (int p0, android.bluetooth.le.ScanResult p1)
	{
		n_onScanResult (p0, p1);
	}

	private native void n_onScanResult (int p0, android.bluetooth.le.ScanResult p1);

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
