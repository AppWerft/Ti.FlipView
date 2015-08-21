package de.manumaticx.androidflip;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;


@Kroll.module(name="Androidflip", id="de.manumaticx.androidflip")
public class AndroidflipModule extends KrollModule
{
	@Kroll.constant public static final String ORIENTATION_VERTICAL = "vertical";
	@Kroll.constant public static final String ORIENTATION_HORIZONTAL = "horizontal";
	@Kroll.constant public static final int OVERFLIPMODE_GLOW = 1;
	@Kroll.constant public static final int OVERFLIPMODE_RUBBER_BAND = 2;
	
	public AndroidflipModule() {
		super();
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app) {
		
	}
}

