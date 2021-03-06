package
{	
	//bit101 components
	import com.bit101.components.Label;
	import com.bit101.components.Text;
	import com.bmcdo248.SpeechExtension.events.SpeechEvent;
	import com.bmcdo248.SpeechExtension.speechDiplomat.SpeechDiplomat;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	public class Conversation
	{
		//speech recognition object
		private var speechDiplomat:SpeechDiplomat;
		private var speechPhrase:String = "";
		
		//dialog components
		public var lineVector:Vector.<Line>;
		public var displayer:Sprite;
		
		//holds the unique words of each response
		public var response1Processed:Array = new Array();
		public var response2Processed:Array = new Array();
		public var response3Processed:Array = new Array();
		
		//holds the phrase the user spoke loaded via data event handler
		private var speechPhraseArray:Array = new Array();
		
		//UI Elements
		public var topBorder: Sprite = new Sprite();
		public var speakerName:Label = new Label();
		public var currentPhrase:Label = new Label();		
		public var bottomBorder: Sprite = new Sprite();
		public var response1:Label = new Label();
		public var response2:Label = new Label();
		public var response3:Label = new Label();
		
		//Variables
		private var lineToProcess:int = 0;
		private var endOfConversation:Boolean = false;
		private var thresh:Number = .0; // this is a constant don't change under penalty of death
		private var nextSegment:Number = 0;

		public function Conversation(lineVector:Vector.<Line>, displayer:Sprite)
		{
			//bring in vectors from episode class
			this.lineVector = lineVector;
			this.displayer = displayer;
			
			//initalization steps
			initializeSpeech();
			//initializeMouse();
			initalizeUI();
			
			processLine(lineVector[0]);
		}
		
		private function initializeSpeech():void
		{	
			//begins speech recognition using the SAPI native extension.
			speechDiplomat = new SpeechDiplomat();
			speechDiplomat.addEventListener(SpeechEvent.DATA, dataEventHandler);
			speechDiplomat.startSpeech()
		}
		
		private function initializeMouse():void
		{	
			//begins speech recognition using the SAPI native extension.
			response1.addEventListener(MouseEvent.CLICK, responseClicked);
			response2.addEventListener(MouseEvent.CLICK, responseClicked);
			response3.addEventListener(MouseEvent.CLICK, responseClicked);
		}
		
		private function initalizeUI():void
		{
			topBorder.graphics.beginFill(0x000000);
			topBorder.graphics.drawRect(0,0,1000,50);
			topBorder.graphics.endFill();
			topBorder.x = 0;
			topBorder.y = 0;
			displayer.addChild(topBorder);
			
			speakerName.text = "";
			speakerName.x = 30;
			speakerName.y = 30;
			displayer.addChild(speakerName);
			
			currentPhrase.text = "";
			currentPhrase.x = 200;
			currentPhrase.y = 7;
			displayer.addChild(currentPhrase);
			
			bottomBorder.graphics.beginFill(0x000000);
			bottomBorder.graphics.drawRect(0,0,1000,50);
			bottomBorder.graphics.endFill();
			bottomBorder.x = 0;
			bottomBorder.y = 325;
			displayer.addChild(bottomBorder);
			
			response1.text = "blank";
			response1.x = 30;
			response1.y = 325;
			displayer.addChild(response1);
			
			response2.text = "blank";
			response2.x = 30;
			response2.y = 340;
			displayer.addChild(response2);
			
			response3.text = "blank";
			response3.x = 30;
			response3.y = 355;
			displayer.addChild(response3);
		}
		
		//Orci: loops until conversatoin is over in order to stall episode code
		public function run():Number
		{
			while(!endOfConversation){}
			trace("End of conversation. Next segment is: " + nextSegment);
			return -1 * nextSegment;//invert segment number to make it positive - 0 is end of episode
		}
		
		//Orci: Advance based on mouse click
		private function responseClicked(e:MouseEvent):void
		{
			var nextLine:Number;
			if (e.target == response1)
			{
				nextLine = lineVector[lineToProcess].responses[0]
			}
			else if(e.target == response2)
			{
				nextLine = lineVector[lineToProcess].responses[0]
			}
			else
			{
				nextLine = lineVector[lineToProcess].responses[0]
			}
			
			if(nextLine > 0)
				processLine(lineVector[nextLine]);
			else //done with segment, go to next
			{
				nextSegment = nextLine;
				endOfConversation = true;
			}
		}
		
		private function dataEventHandler(e:SpeechEvent):void
		{
			//get the current phrase from the recognizer as e.data
			speechPhrase = e.data;
			currentPhrase.text = speechPhrase;
			
			//attempt to recognize any one of the unique words from the speech input array
			var speechPhraseLower:String = speechPhrase.toLowerCase();
			speechPhraseArray= speechPhraseLower.split(" ");
			
			//Counts for each response
			var resp1Count:int;
			var resp2Count:int;
			var resp3Count:int;
			trace("Grabbed speech");
			
			
			for each (var phraseWord:String in speechPhraseArray)
			{
				trace(phraseWord + " " + response3Processed);
				if(response1Processed.indexOf(phraseWord) > -1)
				{
					resp1Count++;
				}
				else if(response2Processed.indexOf(phraseWord) > -1)
				{
					resp2Count++;
				}
				else if(response3Processed.indexOf(phraseWord) > -1)
				{
					resp3Count++;
				}
			}
			trace("counts: " + resp1Count + "  " + resp2Count + "  " + resp3Count);
			
			var resp1Ratio:Number = resp1Count / response1Processed.length;
			var resp2Ratio:Number = resp2Count / response2Processed.length;
			var resp3Ratio:Number = resp3Count / response3Processed.length;
			trace("ratios: " + resp1Ratio + "  " + resp2Ratio + "  " + resp3Ratio);
			
			var match:Boolean = false;
			var nextLine:Number = 0;
			if (resp1Ratio > resp2Ratio && resp3Ratio > resp1Ratio)
			{
				if(resp1Ratio > thresh)
				{
					match=true;
					nextLine = lineVector[lineToProcess].responses[0]
				}
			}	
			else if (resp1Ratio > resp2Ratio && resp3Ratio > resp1Ratio)
			{
				if(resp2Ratio > thresh)
				{
					match=true;
					nextLine = lineVector[lineToProcess].responses[0]
				}
					processLine(lineVector[lineVector[lineToProcess].responses[1]]);
			}
			else
			{
				if(resp3Ratio > thresh)
				{
					match=true;
					nextLine = lineVector[lineToProcess].responses[0]
				}
					processLine(lineVector[lineVector[lineToProcess].responses[2]]);
			}
			trace(match);
			if (match)
			{
				trace(nextLine);
				if(nextLine > 0)
					processLine(lineVector[nextLine]);
				else //done with segment, go to next
				{
					nextSegment = nextLine;
					endOfConversation = true;
				}
			}
		}
		
		private function finalizeApp():void
		{
			speechDiplomat.dispose();
		}
		
		private function processLine(line:Line):void
		{
			trace("LINE IS FUCKING PROCESSING: " + line.lineID);
			//reads in the data for this line and its associated player responses
			speakerName.text = lineVector[line.lineID].speaker;
			response1.text = lineVector[lineVector[line.lineID].responses[0]].lineText;
			response2.text = lineVector[lineVector[line.lineID].responses[1]].lineText;
			response3.text = lineVector[lineVector[line.lineID].responses[2]].lineText;
			var allWords:String = response1.text.toLowerCase() + " " + response2.text.toLowerCase() + " " + response3.text.toLowerCase();
			
			//Takes all words from the current line as input and removes all words occuring more than once.
			for each (var word:String in allWords.split(" "))
			{
				var countArray:Array = allWords.split(" " + word + " ");
				var count:int = countArray.length - 1; 
				if(count >= 2)
				{
					for (var i:Number=0; i<count; i++)
					{ 
						allWords = allWords.replace(" " + word + " ", " ");
					}
				}
			}
			var response1String:String = response1.text.toLowerCase();
			var response1Array:Array = response1String.split(" ");
							
			var response2String:String = response2.text.toLowerCase();
			var response2Array:Array = response2String.split(" ");
						
			var response3String:String = response3.text.toLowerCase();
			var response3Array:Array = response3String.split(" ");
			
			//uses the all words list to determine the unique words in each response and sorts them accordingly
			for each (var processedWord:String in allWords.split(" "))
			{
				for each (var resp1Word:String in response1Array)
				{						
					if(processedWord == resp1Word)
					{
						response1Processed.push(resp1Word);
					}
				}

				for each (var resp2Word:String in response2Array)
				{						
					if(processedWord == resp2Word)
					{
						response2Processed.push(resp2Word);
					}
				}

				for each (var resp3Word:String in response3Array)
				{						
					if(processedWord == resp3Word)
					{
						response3Processed.push(resp3Word);
					}
				}	
			}
		}
		
	}
}