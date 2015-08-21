package de.manumaticx.androidflip;

import java.util.ArrayList;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.view.TiUIView;

import se.emilsjolander.flipview.FlipView;
import se.emilsjolander.flipview.OverFlipMode;
import android.app.Activity;

public class TiFlipView extends TiUIView implements FlipView.OnFlipListener {
	
	private static final String TAG = "de.manumaticx.androidflip";
	
	public static final String PROPERTY_ORIENTATION = "orientation";
	public static final String PROPERTY_OVERFLIPMODE = "overFlipMode";
	
	private FlipView mFlipView;
	private final ArrayList<TiViewProxy> mViews;
	private final FlipViewAdapter mAdapter;
	private int mCurIndex = 0;
	
	public TiFlipView(TiViewProxy proxy) {
		super(proxy);
		Activity activity = proxy.getActivity();
		mViews = new ArrayList<TiViewProxy>();
		
		mAdapter = new FlipViewAdapter(activity, mViews);
		mFlipView = new FlipView(activity);
		mFlipView.setAdapter(mAdapter);
		mFlipView.setOnFlipListener(this);
	}
	
	public void onFlippedToPage(FlipView v, int position, long id) {
		
		mCurIndex = position;
		
		if (proxy.hasListeners("flipped")) {
			KrollDict options = new KrollDict();
			options.put("index", position);
			proxy.fireEvent("flipped", options);
		}
	}

	@Override
	public void processProperties(KrollDict d)
	{
		if (d.containsKey(TiC.PROPERTY_VIEWS)) {
			setViews(d.get(TiC.PROPERTY_VIEWS));
		}
		
		if (d.containsKey(TiC.PROPERTY_CURRENT_PAGE)) {
			int page = TiConvert.toInt(d, TiC.PROPERTY_CURRENT_PAGE);
			if (page > 0) {
				setCurrentPage(page);
			}
		}
		
		if (d.containsKey(PROPERTY_ORIENTATION)) {
			mFlipView.setOrientation((String) d.get(PROPERTY_ORIENTATION));
		}
		
		if (d.containsKey(PROPERTY_OVERFLIPMODE)) {
			int mode = TiConvert.toInt(d, PROPERTY_OVERFLIPMODE);
			
			if (mode == AndroidflipModule.OVERFLIPMODE_GLOW) {
				mFlipView.setOverFlipMode(OverFlipMode.GLOW);
			}
			
			if (mode == AndroidflipModule.OVERFLIPMODE_RUBBER_BAND) {
				mFlipView.setOverFlipMode(OverFlipMode.RUBBER_BAND);
			}
		}
		
		setNativeView(mFlipView);
		
		super.processProperties(d);
	}
	
	@Override
	public void propertyChanged(String key, Object oldValue, Object newValue, KrollProxy proxy) {
		
		if (TiC.PROPERTY_CURRENT_PAGE.equals(key)) {
			setCurrentPage(TiConvert.toInt(newValue));
		} else if (key.equals(TiC.PROPERTY_VIEWS)) {
			setViews(newValue);
		} else if (key.equals(PROPERTY_ORIENTATION)) {
			mFlipView.setOrientation((String) newValue);
		} else if (key.equals(PROPERTY_OVERFLIPMODE)) {
			mFlipView.setOverFlipMode((OverFlipMode) newValue);
		} else {
			super.propertyChanged(key, oldValue, newValue, proxy);
		}
	}
	
	private void clearViewsList()
	{
		if (mViews == null || mViews.size() == 0) {
			return;
		}
		for (TiViewProxy viewProxy : mViews) {
			viewProxy.releaseViews();
			viewProxy.setParent(null);
		}
		mViews.clear();
	}
	
	public void setViews(Object viewsObject)
	{
		boolean changed = false;
		clearViewsList();

		if (viewsObject instanceof Object[]) {
			Object[] views = (Object[])viewsObject;
			Activity activity = this.proxy.getActivity();
			for (int i = 0; i < views.length; i++) {
				if (views[i] instanceof TiViewProxy) {
					TiViewProxy tv = (TiViewProxy)views[i];
					tv.setActivity(activity);
					tv.setParent(this.proxy);
					mViews.add(tv);
					changed = true;
				}
			}
		}
		if (changed) {
			mAdapter.notifyDataSetChanged();
		}
	}
	
	public ArrayList<TiViewProxy> getViews()
	{
		return mViews;
	}
	
	public void addView(TiViewProxy proxy)
	{
		if (!mViews.contains(proxy)) {
			proxy.setActivity(this.proxy.getActivity());
			proxy.setParent(this.proxy);
			mViews.add(proxy);
			getProxy().setProperty(TiC.PROPERTY_VIEWS, mViews.toArray());
			mAdapter.notifyDataSetChanged();
		}
	}

	public void removeView(TiViewProxy proxy)
	{
		if (mViews.contains(proxy)) {
			mViews.remove(proxy);
			proxy.setParent(null);
			getProxy().setProperty(TiC.PROPERTY_VIEWS, mViews.toArray());
			mAdapter.notifyDataSetChanged();
		}
	}
	
	public void moveNext()
	{
		move(mCurIndex + 1, true);
	}

	public void movePrevious()
	{
		move(mCurIndex - 1, true);
	}

	private void move(int index, boolean smoothFlip)
	{
		if (index < 0 || index >= mViews.size()) {
			if (Log.isDebugModeEnabled()) {
				Log.w(TAG, "Request to move to index " + index+ " ignored, as it is out-of-bounds.", Log.DEBUG_MODE);
			}
			return;
		}
		mCurIndex = index;
		
		if (smoothFlip) {
			mFlipView.smoothFlipTo(index);
		} else {
			mFlipView.flipTo(index);
		}
	}
	
	public void flipTo(Object view)
	{
		if (view instanceof Number) {
			move(((Number) view).intValue(), true);
		} else if (view instanceof TiViewProxy) {
			move(mViews.indexOf(view), true);
		}
	}
	
	public int getCurrentPage()
	{
		return mCurIndex;
	}

	public void setCurrentPage(Object view)
	{
		if (view instanceof Number) {
			move(((Number) view).intValue(), false);
		} else if (Log.isDebugModeEnabled()) {
			Log.w(TAG, "Request to set current page is ignored, as it is not a number.", Log.DEBUG_MODE);
		}
	}
	
	public void peakNext(boolean once)
	{
		mFlipView.peakNext(once);
	}
	
	public void peakPrevious(boolean once)
	{
		mFlipView.peakPrevious(once);
	}
}