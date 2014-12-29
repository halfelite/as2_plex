/***************************************************
* Copyright (c) Syabas Technology Sdn. Bhd.
* All Rights Reserved.
*
* The information contained herein is confidential property of Syabas Technology Sdn. Bhd.
* The use of such information is restricted to Syabas Technology Sdn. Bhd. platform and
* devices only.
*
* THIS SOURCE CODE IS PROVIDED ON AN "AS-IS" BASIS WITHOUT WARRANTY OF ANY KIND AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL Syabas Technology Sdn. Bhd. BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS UPDATE, EVEN IF Syabas Technology Sdn. Bhd.
* HAS BEEN ADVISED BY USER OF THE POSSIBILITY OF SUCH POTENTIAL LOSS OR DAMAGE.
* USER AGREES TO HOLD Syabas Technology Sdn. Bhd. HARMLESS FROM AND AGAINST ANY AND
* ALL CLAIMS, LOSSES, LIABILITIES AND EXPENSES.
*
* Version 1.0.9
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: The Photo deck to be shown on main menu layout
*
***************************************************/

import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.DeckBase;
import com.syabas.as2.plex.model.*;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Grid2;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.PhotoDeck extends DeckBase
{
	private var grid1:Grid2 = null;
	
	private var loadPath:String = null;
	private var loadKey:String = null;
	
	private var focusIndex:Number = -1;
	private var id:String = null;
	
	private var loads:Object = null;
	
	public function destroy():Void
	{
		delete this.loadKey;
		delete this.loadPath;
		
		this.grid1.clear();
		this.grid1.destroy();
		delete this.grid1;
		
		delete this.focusIndex;
		
		delete this.loads;
		
		super.destroy();
	}
	
	public function PhotoDeck(mc:MovieClip)
	{
		super(mc);
		
		this.deckMC.txt_group.htmlText = Share.getString("recently_added");
		this.deckMC.mc_arrowPointer._visible = false;
		
		this.config = Share.APP_SETTING.mainMenuConfig.photoDeckConfig;
		this.loads = new Object();
		this.createGrid();
	}
	
	/*
	 * Overwrite super class
	 */
	public function available():Boolean
	{
		return this.deckMC._visible;
	}
	
	/*
	 * Overwrite super class
	 */
	public function showDeck(item:MediaModel, pointerMC:MovieClip):Void
	{
		this.isShown = true;
		
		this.pointerMC = pointerMC;
		pointerMC._visible = false;
		
		this.loadPath = "/library/sections/";
		this.loadKey = item.key;
		
		this.grid1.clear();
		this.grid1.totalRecord = 100;
		this.grid1.createUI();
	}
	
	/*
	 * Overwrite super class
	 */
	public function hideDeck():Void
	{
		this.isShown = false;
		this.deckMC._visible = false;
		this.grid1.clear();
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		this.focusIndex = 0;
		this.grid1.highlight();
		this.pointerMC._visible = true;
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.focusIndex = -1;
		this.titleMarquee.stop();
		
		this.grid1.unhighlight();
		
		this.deckMC.txt_title.text = "";
		this.pointerMC._visible = false;
	}
	
	
	//----------------------------------------- Grid --------------------------------------------
	private function createGrid():Void
	{
		var row:Number = 1;
		var column:Number = this.config.itemColumn;
		var mcArrayAll:Array = UI.attachMovieClip( { parentMC:this.deckMC, rSize:row, cSize:column } );
		
		this.grid1 = new Grid2();
		
		this.grid1.xMCArray = mcArrayAll;
		this.grid1.hlCB = Delegate.create(this, this.cellHLCB);
		this.grid1.unhlCB = Delegate.create(this, this.cellUnHLCB);
		this.grid1.onItemUpdateCB = Delegate.create(this, this.cellUpdateCB);
		this.grid1.onItemClearCB = Delegate.create(this, this.cellClearCB);
		this.grid1.onEnterCB = Delegate.create(this, this.cellOnEnterCB);
		this.grid1.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.grid1.loadDataCB = Delegate.create(this, this.recentLoadDataCB);
		this.grid1.onItemShowCB = Delegate.create(this, this.cellOnShowCB);
		this.grid1.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		
		this.grid1.totalRecord = 100;
		this.grid1.xMaxLoad = 3;
		this.grid1.xLoadSize = 30;
		this.grid1.xWrap = false;
		this.grid1.xWrapLine = false;
		this.grid1.xHoriz = true;
		this.grid1.xEnablePageMove = true;
		this.grid1.xScroll = Grid2.SCROLL_PAGE;
		
		this.grid1.clear();
	}
	
	private function recentLoadDataCB(startIndex:Number, loadSize:Number):Void
	{
		var key:String = this.loadKey + (Util.endsWith(this.loadKey, "/") ? "recentlyAdded" : "/recentlyAdded");
		key = Share.getPaginationKey(key, startIndex, loadSize);
		Share.api.load(key, this.loadPath, Share.systemGateway, { loadTarget:"recent", start:startIndex, key:this.loadKey }, Delegate.create(this, this.dataOnLoaded), "recent");
	}
	
	private function dataOnLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (this.isShown != true)
		{
			return;
		}
		
		if (userparams.key != this.loadKey)
		{
			return;
		}
		
		var target:String = userparams.loadTarget;
		if (success)
		{
			if (data.items.length > 0)
			{
				this.id = data.identifier;
				this.deckMC._visible = true;
				this.grid1.onLoadDataCB(data.items, data.size);
				
				var startIndex = userparams.start;
				this.loads[startIndex + ""] = data;
			}
		}
		else
		{
			this.grid1.skipLoadData();
		}
	}
	
	private function cellUpdateCB(o:Object):Void
	{
		if (o.data.mcName == o.mc._name)
		{
			// previously rendered in onItemShowCB
			return;
		}
		
		if (o.data != null && o.data != undefined)
		{
			var thumbURL:String = o.data.media[0].parts[0].key;
			
			
			// Create Mask for the thumbnail
			if (o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == null || o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == undefined)
			{
				Share.createMask(o.mc, o.mc.mc_thumbnail, this.config.itemThumbnailConfig);
			}
			
			thumbURL = Share.getResourceURL(thumbURL);
			
			Share.loadThumbnail(o.mc._name, o.mc.mc_thumbnail, thumbURL, this.config.itemThumbnailConfig);
			
			o.mc._visible = true;
			o.mc.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
			
			if (o.dataIndex == this.grid1._hl && this.focusIndex == 0)
			{
				o.mc.gotoAndStop("unhl");
				o.mc.gotoAndStop("hl");
			}
		}
	}
	
	private function cellClearCB(o:Object):Void
	{
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		o.mc.txt_title.text = "";		
		o.mc._visible = false;
	}
	
	private function cellHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
		if (this.titleMarquee.isRunning())
		{
			this.titleMarquee.stop();
		}
		this.pointerMC._y = this.config.pointerYValue[0];
		this.clearFanartCB();
		
		if (o.data != null && o.data != undefined)
		{
			this.deckMC.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
			Share.startMarquee(this.titleMarquee, this.deckMC.txt_title, this.config.titleMarqueeConfig);
			
			var fanartURL:String = o.data.art;
			
			if (fanartURL != null && fanartURL != undefined)
			{
				fanartURL = Share.getResourceURL(fanartURL);
				this.loadFanartCB(fanartURL);
			}
		}
		
	}
	
	private function cellUnHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function cellOnShowCB(o:Object):Void
	{
		o.data.mcName = null;
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		thumbnailMC.removeMovieClip();
		
		if (o.data == null || o.data == undefined)
		{
			o.mc.txt_title.text = "";
			
		}
		else
		{
			this.cellUpdateCB(o);
			o.data.mcName = o.mc._name;
		}
	}
	
	private function cellOnEnterCB(o:Object):Void
	{
		var index:Number = o.dataIndex;
		var loadID:Number = Math.floor(index / this.grid1.xLoadSize) * this.grid1.xLoadSize;
		var container:ContainerModel = null;
		
		container = this.loads[loadID + ""];
		
		index = index - loadID;
		
		Share.PLAYER.startBatchPlayback(container, index, true, (this.loadKey + (Util.endsWith(this.loadKey, "/") ? "recentlyAdded" : "/recentlyAdded")), this.loadPath);
		this.disable();
	}
	
	private function overLeftCB(o:Object):Void
	{
		this.overLeft();
		this.disable();
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		
		switch (keyCode)
		{
			case Key.BACK:
				this.overLeftCB();
				break;
		}
	}
}