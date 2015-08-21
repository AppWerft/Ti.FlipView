package de.manumaticx.androidflip;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;

import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;

public class FlipViewAdapter extends BaseAdapter {
	
	private final ArrayList<TiViewProxy> mViewProxies;
	protected final Context context;
	
	public FlipViewAdapter (Activity activity, ArrayList<TiViewProxy> viewProxies) {
		this.context = activity.getBaseContext();
		mViewProxies = viewProxies;
	}

	public int getCount() {
		return mViewProxies.size();
	}

	public Object getItem(int position) {
		if (position >= getCount()) return null;
        return mViewProxies.get(position);
	}

	public long getItemId(int position) {
        return position;
    }

	public View getView(int position, View convertView, ViewGroup parent) {
		
		TiViewProxy tiProxy = mViewProxies.get(position);
		TiUIView tiView = tiProxy.getOrCreateView();
		View view = tiView.getOuterView();
		
		return view;
	}

}
