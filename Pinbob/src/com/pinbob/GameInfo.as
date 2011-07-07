package com.pinbob
{
	public class GameInfo
	{
		public static const LEVEL_COUNT:int = 3;
		
		/**
		 * game information
		 * time (second)
		 * startPts [x, y]
		 * endPts [x, y]
		 * bonus [[..]]
		 */
		private var gameInfo:Array = 
			[{time:120,startPts:[90,200],endPts:[470,200],bonus:null,mapUrl:'map1.png'},
			 {time:120,startPts:[130,100],endPts:[410,300],bonus:[410,100],mapUrl:'map2.png'},
			 {time:120,startPts:[130,100],endPts:[410,300],bonus:[310,300],mapUrl:'map3.png'}];
		
		public function GameInfo(){
		}
		
		/**
		 * gets the game time of the specific level
		 * @param level the game level given
		 */
		public function getTime(level:int):int {
			return this.gameInfo[level].time;
		}
		
		/**
		 * gets the start point of the specific level
		 * @param level the game level given
		 */
		public function getStartPoint(level:int):Array {
			return this.gameInfo[level].startPts;
		}
		
		/**
		 * gets the end point of the specific level
		 * @param level the game level given
		 */
		public function getEndPoint(level:int):Array {
			return this.gameInfo[level].endPts;
		}
		
		/**
		 * gets the map url of the specific level
		 * @param level the game level given
		 */
		public function getMapUrl(level:int):String {
			return this.gameInfo[level].mapUrl;
		}
	}
}