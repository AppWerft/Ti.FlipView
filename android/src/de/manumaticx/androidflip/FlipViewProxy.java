package de.manumaticx.androidflip;

import java.util.ArrayList;
import java.util.List;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.AsyncResult;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiMessenger;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.view.TiUIView;

import android.app.Activity;
import android.os.Message;


@Kroll.proxy(creatableInModule=AndroidflipModule.class)
public class FlipViewProxy extends TiViewProxy {
	
	private static final String TAG = "de.manumaticx.androidflip";
	
	private static final int MSG_FIRST_ID = TiViewProxy.MSG_LAST_ID + 1;
	public static final int MSG_MOVE_PREV = MSG_FIRST_ID + 101;
	public static final int MSG_MOVE_NEXT = MSG_FIRST_ID + 102;
	public static final int MSG_FLIP_TO = MSG_FIRST_ID + 103;
	public static final int MSG_SET_VIEWS = MSG_FIRST_ID + 104;
	public static final int MSG_ADD_VIEW = MSG_FIRST_ID + 105;
	public static final int MSG_SET_CURRENT = MSG_FIRST_ID + 106;
	public static final int MSG_REMOVE_VIEW = MSG_FIRST_ID + 107;
	public static final int MSG_PEAK_PREV = MSG_FIRST_ID + 108;
	public static final int MSG_PEAK_NEXT = MSG_FIRST_ID + 109;
	public static final int MSG_LAST_ID = MSG_FIRST_ID + 999;

	public FlipViewProxy() {
		super();
	}

	@Override
	public TiUIView createView(Activity activity) {
		
		TiUIView flipview = new TiFlipView(this);
		flipview.getLayoutParams().autoFillsHeight = true;
		flipview.getLayoutParams().autoFillsWidth = true;
		return flipview;
	}
	
	protected TiFlipView getView() {
		return (TiFlipView) getOrCreateView();
	}
	
	public boolean handleMessage(Message msg)
	{
		boolean handled = false;

		switch(msg.what) {
			case MSG_MOVE_PREV:
				getView().movePrevious();
				handled = true;
				break;
			case MSG_MOVE_NEXT:
				getView().moveNext();
				handled = true;
				break;
			case MSG_FLIP_TO:
				getView().flipTo(msg.obj);
				handled = true;
				break;
			case MSG_SET_CURRENT:
				getView().setCurrentPage(msg.obj);
				handled = true;
				break;
			case MSG_SET_VIEWS: {
				AsyncResult holder = (AsyncResult) msg.obj;
				Object views = holder.getArg(); 
				getView().setViews(views);
				holder.setResult(null);
				handled = true;
				break;
			}
			case MSG_ADD_VIEW: {
				AsyncResult holder = (AsyncResult) msg.obj;
				Object view = holder.getArg();
				if (view instanceof TiViewProxy) {
					getView().addView((TiViewProxy) view);
					handled = true;
				} else if (view != null) {
					Log.w(TAG, "addView() ignored. Expected a Titanium view object, got " + view.getClass().getSimpleName());
				}
				holder.setResult(null);
				break;
			}
			case MSG_REMOVE_VIEW: {
				AsyncResult holder = (AsyncResult) msg.obj;
				Object view = holder.getArg(); 
				if (view instanceof TiViewProxy) {
					getView().removeView((TiViewProxy) view);
					handled = true;
				} else if (view != null) {
					Log.w(TAG, "removeView() ignored. Expected a Titanium view object, got " + view.getClass().getSimpleName());
				}
				holder.setResult(null);
				break;
			}
			case MSG_PEAK_PREV:
				getView().peakPrevious((Boolean) msg.obj);
				handled = true;
				break;
			case MSG_PEAK_NEXT:
				getView().peakNext((Boolean) msg.obj);
				handled = true;
				break;
			default:
				handled = super.handleMessage(msg);
		}

		return handled;
	}
	
	@Kroll.getProperty @Kroll.method
	public Object getViews()
	{
		List<TiViewProxy> list = new ArrayList<TiViewProxy>();
		return getView().getViews().toArray(new TiViewProxy[list.size()]);
	}

	@Kroll.setProperty @Kroll.method
	public void setViews(Object viewsObject)
	{
		TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(MSG_SET_VIEWS), viewsObject);
	}

	@Kroll.method
	public void addView(Object viewObject)
	{
		TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(MSG_ADD_VIEW), viewObject);
	}

	@Kroll.method
	public void removeView(Object viewObject)
	{
		TiMessenger.sendBlockingMainMessage(getMainHandler().obtainMessage(MSG_REMOVE_VIEW), viewObject);
	}

	@Kroll.method
	public void flipToView(Object view)
	{
		getMainHandler().obtainMessage(MSG_FLIP_TO, view).sendToTarget();
	}

	@Kroll.method
	public void movePrevious()
	{
		getMainHandler().removeMessages(MSG_MOVE_PREV);
		getMainHandler().sendEmptyMessage(MSG_MOVE_PREV);
	}

	@Kroll.method
	public void moveNext()
	{
		getMainHandler().removeMessages(MSG_MOVE_NEXT);
		getMainHandler().sendEmptyMessage(MSG_MOVE_NEXT);
	}
	
	@Kroll.getProperty @Kroll.method
	public int getCurrentPage()
	{
		return getView().getCurrentPage();
	}

	@Kroll.setProperty @Kroll.method
	public void setCurrentPage(Object page)
	{
		getMainHandler().obtainMessage(MSG_SET_CURRENT, page).sendToTarget();
	}
	
	@Kroll.method
	public void peakPrevious(@Kroll.argument(optional = true) Boolean arg)
	{
		Boolean once = false;
		
		if (arg != null) {
			once = TiConvert.toBoolean(arg);
		}
		
		getMainHandler().obtainMessage(MSG_PEAK_PREV, once).sendToTarget();
	}

	@Kroll.method
	public void peakNext(@Kroll.argument(optional = true) Boolean arg)
	{
		Boolean once = false;
		
		if (arg != null) {
			once = TiConvert.toBoolean(arg);
		}
		
		getMainHandler().obtainMessage(MSG_PEAK_NEXT, once).sendToTarget();
	}
}