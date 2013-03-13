//
//  DozenalViewController.m
//  Dozenal Clock
//
//  Created by Devine Lu Linvega on 2013-01-31.
//  Copyright (c) 2013 XXIIVV. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "DozenalViewController.h"
#import "DozenalViewController_WorldNode.h"
#import "DozenalViewController_Templates.h"

// Extras
#define M_PI   3.14159265358979323846264338327950288   /* pi */
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

// World
NSArray			*worldPath;
NSArray			*worldActionType;
NSString        *worldNodeImg = @"empty";
NSString		*worldNodeImgId;

// Puzzle
int				puzzleTerminal;
int				puzzleState;

// User
int             userId;
NSString        *userAction;
int             userNode = 0;
int             userOrientation;
NSMutableArray	*userActionStorage;
NSString        *userActionType;
int				userActionId;

int				userSeal = 0;
int				userEnergy = 0;
int				userFold = 0;
int				userCollectible = 1;

int				userFootstep = 0;

@interface DozenalViewController ()
@end

@implementation DozenalViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
	worldPath = [self worldPath];
	worldActionType = [self worldActionType];
	
	userActionStorage = [NSMutableArray arrayWithObjects:@"",@"0",@"",@"",@"",@"0",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",nil];
	
//	userActionStorage[21] = @"1";
//	userActionStorage[12] = @"1";
//	userActionStorage[5] = @"2";
	
	[self actionCheck];
    [self moveCheck];
	
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// ====================
// Movement
// ====================

- (void)moveCheck
{
	[self actionReset];
	
	self.debugNode.text = [NSString stringWithFormat:@"%d", userNode];
	self.debugOrientation.text = [NSString stringWithFormat:@"%d", userOrientation];
	self.debugAction.text = [NSString stringWithFormat:@"%@", worldPath[userNode][userOrientation]];
	
//	self.debugNode.alpha = 0;
//	self.debugOrientation.alpha = 0;
//	self.debugAction.alpha = 0;
	
	self.moveAction.hidden = YES; [self fadeOut:_interfaceVignette t:1];
    self.moveForward.hidden = worldPath[userNode][userOrientation] ? NO : YES;
	self.moveAction.hidden = [[NSCharacterSet letterCharacterSet] characterIsMember:[worldPath[userNode][userOrientation] characterAtIndex:0]] ? NO : YES;
	
	worldNodeImgId = [NSString stringWithFormat:@"%04d", (userNode*4)+userOrientation ];
	worldNodeImg = [NSString stringWithFormat:@"%@%@%@", @"node.", worldNodeImgId, @".jpg"];
	self.viewMain.image = [UIImage imageNamed:worldNodeImg];
	
}

- (IBAction)moveLeft:(id)sender {
    
	[self audioTurn];
	
    userOrientation = userOrientation == 0 ? 3 : userOrientation-1;

	[self turnLeft];
    [self moveCheck];
    
}

- (IBAction)moveRight:(id)sender {
    
	[self audioTurn];
	
    userOrientation = userOrientation < 3 ? userOrientation+1 : 0;
    
	[self turnRight];
    [self moveCheck];
    
}

- (IBAction)moveForward:(id)sender {
	
    [self audioRouterMove];
	
	if ([worldPath[userNode][userOrientation] rangeOfString:@"|"].location == NSNotFound) {
		userNode = [ worldPath[userNode][userOrientation] intValue] > 0 ? [ worldPath[userNode][userOrientation] intValue] : userNode;
	} else {
		NSArray *temp = [worldPath[userNode][userOrientation] componentsSeparatedByString:@"|"];
		userNode = [ worldPath[userNode][userOrientation] intValue] > 0 ? [ temp[0] intValue] : userNode;
		userOrientation = [ temp[1] intValue ];
	}
	
	[self turnForward];
    [self moveCheck];
	
}

- (IBAction)moveAction:(id)sender {
    
    userAction = worldPath[userNode][userOrientation];
    	
    [self actionCheck];

}

- (IBAction)moveReturn:(id)sender {
    
	[self audioReturn];
	
    userAction = nil;
    
    [self actionCheck];
    [self moveCheck];
	[self actionReset];
    
}

// ====================
// Interactions
// ====================

- (void)actionCheck
{
    
    self.moveLeft.hidden = userAction ? YES : NO;
    self.moveRight.hidden = userAction ? YES : NO;
    self.moveForward.hidden = userAction ? YES : NO;
    self.moveReturn.hidden = userAction ? NO : YES;
    self.moveAction.hidden = userAction ? YES : NO;
	
	self.action1.hidden = YES;
	self.action2.hidden = YES;
	self.action3.hidden = YES;
	self.action4.hidden = YES;
	self.action5.hidden = YES;
	
    if( userAction ){
        
        [self actionRouting];
		[self actionTemplate];
		[self fadeIn:_interfaceVignette t:1];
		[self fadeIn:_moveReturn t:1];
		
    }
    
}

- (void)actionTemplate
{
	
	[self actionReset];
	
	// ====================
	// Clock Terminal
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"clockTerminal"]){
		
		[self audioClockInit];
		
		[self.action1 setImage:[UIImage imageNamed:@"action0101.png"] forState:UIControlStateNormal];
		self.action1.frame = CGRectMake(80, 140, 160, 160);
		[self fadeIn:self.action1 t:1];
		[self rotate:self.action1 t:2 d:( [userActionStorage[userActionId] intValue] *120 )];
		
		[self fadeIn:self.graphic1 t:1];
		self.graphic1.image = [UIImage imageNamed:@"action0102.png"];
		self.graphic1.frame = CGRectMake(80, 140, 160, 160);
		
	}
	
	// ====================
	// Seal Terminal
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"sealTerminal"]){
		
		[self audioSealInit];
		
		[self.action5 setImage:nil forState:UIControlStateNormal];
		self.action5.frame = CGRectMake(128, 180, 64, 64);
		[self fadeHalf:self.action5 t:1];
		
		[self templateUpdateSeal];
		
	}
		
	// ====================
	// Energy Terminal
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"energyTerminal"]){
		
		[self audioEnergyInit];
		
		self.graphic1.image = [UIImage imageNamed:@"energy_slot0.png"];		
		self.graphic2.image = [UIImage imageNamed:@"energy_userslot0.png"];
		
		self.graphic1.frame = CGRectMake(99, 174, 128, 128);
		self.graphic2.frame = CGRectMake(99, 174, 128, 128);
		self.action4.frame = CGRectMake(99, 174, 128, 128);
		
		[self fadeIn:self.action4 t:1];
		[self fadeIn:self.graphic1 t:0.4];
		[self fadeIn:self.graphic2 t:1.0];
		
		[self templateUpdateEnergy];
		
	}
	
	// ====================
	// Seal Gate
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"sealDoor"] ){
		
		[self audioDoorInit];
		
		if ( [userActionStorage[4] intValue] == 1 && [userActionStorage[13] intValue] == 1 ) { // Forest + Rainre ( Stones Monolith )
			[self  templateUpdateState:46:@"0486":@"act15"];
			[self  templateUpdateState:85:@"0485":@"act15"];
		}
		
		if ( [userActionStorage[21] intValue] == 1 && [userActionStorage[13] intValue] == 1 ) { // Antechannel + Rainre ( Metamondst Door )
			[self  templateUpdateState:46:@"0486":@"act15"];
			[self  templateUpdateState:85:@"0485":@"act15"];
		}
		
		if ( [userActionStorage[20] intValue] == 1 && [userActionStorage[13] intValue] == 1 ) { // Metamondst + Rainre ( Forest Monolith )
			[self  templateUpdateState:11:@"0487":@"act25"];
			[self  templateUpdateState:48:@"0488":@"act25"];
		}
		
		
		if ( [userActionStorage[21] intValue] == 1 && [userActionStorage[12] intValue] == 1 ) { // Antechannel + Stones ( Terminal Seal )
			
			self.graphic1.image = [UIImage imageNamed:@"node.0489.jpg"];
			self.graphic1.frame = CGRectMake(0, 10, 320, 460);
			
			[self.action1 setImage: nil forState: UIControlStateNormal];
			self.action1.frame = CGRectMake(80, 140, 160, 160);
			[self fadeIn:self.action1 t:0];
			
			[self templateUpdateStudioTerminal];
			[self vibrate];
			
		}
		else if( userActionId == 5 ){
			
			[self templateUpdateStudioTerminal];
			
		}
		
	}

	// ====================
	// Energy Door
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"energyDoor"]){
		
		[self audioDoorInit];
		
		if([userAction isEqual: @"act3"]) { puzzleTerminal = 2;  }
		if([userAction isEqual: @"act11"]){ puzzleTerminal = 10; }
		if([userAction isEqual: @"act19"]){ puzzleTerminal = 18; }
		if([userAction isEqual: @"act26"]){ puzzleTerminal = 27; }
		
		if([userAction isEqual: @"act28"]){ puzzleTerminal = 5;  }
		if([userAction isEqual: @"act29"]){ puzzleTerminal = 5;  }
		if([userAction isEqual: @"act30"]){ puzzleTerminal = 5;  }
		
		if( [userActionStorage[puzzleTerminal] intValue] > 1 ){
			
			[self  templateUpdateState:12:@"0470":@"act3"];
			[self  templateUpdateState:13:@"0471":@"act3"];
			[self  templateUpdateState:69:@"0478":@"act19"];
			[self  templateUpdateState:61:@"0479":@"act19"];
			[self  templateUpdateState:62:@"0480":@"act26"];
			[self  templateUpdateState:77:@"0481":@"act26"];
			[self  templateUpdateState:76:@"0482":@"act30"];
			[self  templateUpdateState:87:@"0483":@"act30"];
			
			// Nether Door
			if( [userActionStorage[5] isEqual: @"2"] && userFold == 1 ){
				[self  templateUpdateState:39:@"0491":@"act11"];
			}
			else{
				[self  templateUpdateState:39:@"0490":@"act11"];
			}
			
			self.action3.frame = CGRectMake(0, 10, 320, 460);
			[self fadeIn:self.action3 t:0.5];
			
		}
		else{
			[self audioDoorInactive];
		}
		
	}
	

	// ====================
	// Clock Door
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"clockDoor"]){
		
		[self audioDoorInit];
		
		puzzleState = 0;
		
		if([userAction isEqual: @"act7"]){
			if( [userActionStorage[1] intValue] == 2 || [userActionStorage[1] intValue] == 0 ){
				puzzleState = 1;
			}
		}
		
		if([userAction isEqual: @"act8"]){
			if( [userActionStorage[1] intValue] == 1 || [userActionStorage[1] intValue] == 2 ){
				puzzleState = 1;
			}
		}
		
		if([userAction isEqual: @"act9"]){
			if( [userActionStorage[1] intValue] == 1 || [userActionStorage[1] intValue] == 0 ){
				puzzleState = 1;
			}
		}
		
		if( puzzleState == 1 ){
			
			[self  templateUpdateState:16:@"0472":@"act7"];
			[self  templateUpdateState:23:@"0473":@"act7"];
			[self  templateUpdateState:25:@"0474":@"act8"];
			[self  templateUpdateState:35:@"0475":@"act8"];
			[self  templateUpdateState:27:@"0476":@"act9"];
			[self  templateUpdateState:52:@"0477":@"act9"];
			
		}
		
	}
	
	// ====================
	// Collectible
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"collectible"]){
		
		[self audioCollectibleInit];
		
		if( [userActionStorage[5] intValue] > 1 && ![userActionStorage[userActionId] isEqual: @"1"] ){
			userActionStorage[userActionId] = @"1";
			NSLog(@"Collectible #%d Unlocked", userActionId);
		}
		else if( [userActionStorage[5] intValue] > 1 && [userActionStorage[userActionId] isEqual: @"1"] ){
			NSLog(@"Collectible #%d already Unlocked", userActionId);
		}
		else{
			NSLog(@"Collectibles Inactive");
		}
		
		if( [userActionStorage[5] intValue] > 1 ){
			
			[self  templateUpdateNode:9:@"0514":@"act32"];
			
		}
		
		
		NSLog(@"!!");
		
	}
	
	// ====================
	// Progress Report | Endgame
	// ====================
	
	if( [worldActionType[userActionId] isEqual: @"progressReport"]){
		
		[self audioTerminalInit];
		
		NSLog(@"Collectibles: %d/%d",[self collectibleCount], 10);
		
	}
	
	// ====================
	// Entente
	// ====================
	
	if( [userAction isEqual: @"act23"] ){ // Display Location Part I
		
		if( [ userActionStorage[23] intValue] > 17 ){
			self.graphic1.image = [UIImage imageNamed:@"ententeHi.png"];
		}
		else if( [ userActionStorage[23] intValue] < 17 ){
			self.graphic1.image = [UIImage imageNamed:@"ententeLo.png"];
		}
		else{
			self.graphic1.image = [UIImage imageNamed:@"ententeOn.png"];
		}
		
		self.graphic1.frame = CGRectMake(116, 200, 90, 90);
		[self fadeHalf:self.graphic1 t:1];
		
	}
	
	if( [userAction isEqual: @"act24"] ){ // Display Location Part II
		
		if( [ userActionStorage[24] intValue] > 17 ){
			self.graphic1.image = [UIImage imageNamed:@"ententeHi.png"];
		}
		else if( [ userActionStorage[24] intValue] < 17 ){
			self.graphic1.image = [UIImage imageNamed:@"ententeLo.png"];
		}
		else{
			self.graphic1.image = [UIImage imageNamed:@"ententeOn.png"];
		}
		
		NSLog(@"%@",userActionStorage[24]);
		
		self.graphic1.frame = CGRectMake(116, 200, 90, 90);
		[self fadeHalf:self.graphic1 t:1];
		
	}
		
	if( [userAction isEqual: @"act43"] ){ // Part I - Increment +3
		
		if( [userActionStorage[23] isEqual: @"17"] ){
			userNode = 93;
			userAction = nil;
			[self actionCheck];
			[self moveCheck];
			[self actionReset];
		}
		else{
			userNode = 89;
			userAction = nil;
			
			if( [ userActionStorage[23] intValue] < 30 ){
				userActionStorage[23] = [NSString stringWithFormat:@"%d", [ userActionStorage[23] intValue]+3 ];
			}
			
			NSLog(@"%@",userActionStorage[23]);
			
			[self actionCheck];
			[self moveCheck];
			[self actionReset];
		}

	}
	
	if([userAction isEqual: @"act42"]){ // Part I - Decrement -1
		
		userNode = 103;
		userAction = nil;
		
		if( [ userActionStorage[23] intValue] > 0 ){
			userActionStorage[23] = [NSString stringWithFormat:@"%d", [ userActionStorage[23] intValue]-1 ];
		}
		
		NSLog(@"%@",userActionStorage[23]);
		
		[self actionCheck];
		[self moveCheck];
		[self actionReset];
		
	}
	
	if([userAction isEqual: @"act44"]){ // Part II - Decrement -1
		
		userNode = 91;
		userOrientation = 2;
		userAction = nil;
		
		if( [ userActionStorage[24] intValue] > 0 ){
			userActionStorage[24] = [NSString stringWithFormat:@"%d", [ userActionStorage[24] intValue]-1 ];
		}
		
		NSLog(@"%@",userActionStorage[24]);
		
		[self actionCheck];
		[self moveCheck];
		[self actionReset];
		
	}
	
	if([userAction isEqual: @"act45"]){ // Part II - Increment +4
		
		userNode = 91;
		userOrientation = 2;
		userAction = nil;
		
		if( [ userActionStorage[24] intValue] < 32 ){
			userActionStorage[24] = [NSString stringWithFormat:@"%d", [ userActionStorage[24] intValue]+4 ];
		}
		
		NSLog(@"%@",userActionStorage[24]);
		
		[self actionCheck];
		[self moveCheck];
		[self actionReset];
		
	}
	
	if([userAction isEqual: @"act46"]){ // Part II - Exit
		
		if( [userActionStorage[23] intValue] == 17 && [userActionStorage[24] intValue] == 17 ){
			userNode = 104;
			userOrientation = 3;
			NSLog(@"OUT!");
		}
		else{
			userNode = 92;
		}
		
		
		userAction = nil;
		
		NSLog(@"%@",userActionStorage[24]);
		
		[self actionCheck];
		[self moveCheck];
		[self actionReset];
		
	}
		
	// ====================
	// Fold Gate
	// ====================
	
	if([userAction isEqual: @"act6"] && [userActionStorage[5] isEqual: @"2"] ){ // Fold Gate
		
		userNode = 20;
		userOrientation = 2;
		userAction = nil;
		userFold = ( userFold == 1 ) ? 0 : 1;
		
		NSLog(@"%d",userFold);
		
		[self actionCheck];
		[self moveCheck];
		[self actionReset];
		
	}
	
	// ====================
	// Progress Terminal
	// ====================
	
	if([userAction isEqual: @"act16"]){
		
		self.graphic1.image = [UIImage imageNamed:@"progress_shadows.png"];
		
		self.graphic2.image = [UIImage imageNamed:@"progress_capsule.png"];
		self.graphic3.image = [UIImage imageNamed:@"progress_metamondst.png"];
		self.graphic4.image = [UIImage imageNamed:@"progress_bonus1.png"];
		self.graphic5.image = [UIImage imageNamed:@"progress_bonus2.png"];
		
		self.graphic6.image = [UIImage imageNamed:@"progress_studio.png"];
		self.graphic7.image = [UIImage imageNamed:@"progress_circle.png"];
		self.graphic8.image = [UIImage imageNamed:@"progress_antechannel.png"];
		self.graphic9.image = [UIImage imageNamed:@"progress_bonus3.png"];
		
		self.graphic10.image = [UIImage imageNamed:@"progress_forest.png"];
		self.graphic11.image = [UIImage imageNamed:@"progress_stones.png"];
		self.graphic12.image = [UIImage imageNamed:@"progress_rainre.png"];
		self.graphic13.image = [UIImage imageNamed:@"progress_map.png"];
		
		self.graphic14.image = [UIImage imageNamed:@"progress_entente.png"];
		self.graphic15.image = [UIImage imageNamed:@"progress_bonus6.png"];
		self.graphic16.image = [UIImage imageNamed:@"progress_bonus5.png"];
		self.graphic17.image = [UIImage imageNamed:@"progress_bonus4.png"];
		
		self.graphic1.frame = CGRectMake(61, 70, 200, 314);
		self.graphic2.frame = CGRectMake(61, 70, 200, 314);
		self.graphic3.frame = CGRectMake(61, 70, 200, 314);
		self.graphic4.frame = CGRectMake(61, 70, 200, 314);
		self.graphic5.frame = CGRectMake(61, 70, 200, 314);
		self.graphic6.frame = CGRectMake(61, 70, 200, 314);
		self.graphic7.frame = CGRectMake(61, 70, 200, 314);
		self.graphic8.frame = CGRectMake(61, 70, 200, 314);
		self.graphic9.frame = CGRectMake(61, 70, 200, 314);
		self.graphic10.frame = CGRectMake(61, 70, 200, 314);
		self.graphic11.frame = CGRectMake(61, 70, 200, 314);
		self.graphic12.frame = CGRectMake(61, 70, 200, 314);
		self.graphic13.frame = CGRectMake(61, 70, 200, 314);
		self.graphic14.frame = CGRectMake(61, 70, 200, 314);
		self.graphic15.frame = CGRectMake(61, 70, 200, 314);
		self.graphic16.frame = CGRectMake(61, 70, 200, 314);
		self.graphic17.frame = CGRectMake(61, 70, 200, 314);
		
		[self fadeIn:self.graphic1 t:1];
		
		if( [userActionStorage[24] isEqual: @"1"] ){	[self fadeIn:self.graphic2 t:1]; }
		if( [userActionStorage[20] isEqual: @"1"] ){	[self fadeIn:self.graphic3 t:1]; }
		// 4
		// 5
		
		if( [userActionStorage[14] isEqual: @"1"] ){	[self fadeIn:self.graphic6 t:1]; }
		// 7
		if( [userActionStorage[21] isEqual: @"1"] ){	[self fadeIn:self.graphic8 t:1]; }
		// 9
		
		if( [userActionStorage[4] isEqual: @"1"] ) {	[self fadeIn:self.graphic10 t:1]; }
		if( [userActionStorage[12] isEqual: @"1"] ){	[self fadeIn:self.graphic11 t:1]; }
		if( [userActionStorage[13] isEqual: @"1"] ){	[self fadeIn:self.graphic12 t:1]; }
		// Nothing
		
		if( [userActionStorage[22] isEqual: @"1"] ) {	[self fadeIn:self.graphic14 t:1]; }
		// 15
		// 16
		// 17
		
		
		if( [userActionStorage[22] isEqual: @"1"] ){	[self fadeIn:self.graphic13 t:1]; }
	
	}
	
}

- (void)actionAnimation:sender
{
	if([userAction isEqual: @"act1"]){
		[self rotate:sender t:1.0 d:( [userActionStorage[userActionId] intValue] *120 )];
	}
	
}

- (void)actionRouting
{
	
	userActionType = [userAction substringWithRange:NSMakeRange(0, 3)];
	userActionId  = [[userAction stringByReplacingOccurrencesOfString:userActionType withString:@""] intValue];

	self.action1.hidden = NO;
	self.action2.hidden = NO;
	self.action3.hidden = NO;
	self.action4.hidden = NO;
	self.action5.hidden = NO;
    
	// Unlock Map
	
	if([userAction isEqual: @"act22"]){
		userActionStorage[22] = @"1";
		NSLog(@"Map Unlocked");
	}
	
}

- (IBAction)action1:(id)sender {
	
	userActionStorage[userActionId] = [NSString stringWithFormat:@"%d", [ userActionStorage[userActionId] intValue]+1 ];	
	
	// Exceptions
	
	if([userAction isEqual: @"act1"]){	userActionStorage[userActionId] = [userActionStorage[userActionId] intValue] > 2 ? @"0" : userActionStorage[userActionId]; [self audioClockTurn]; }
	if([userAction isEqual: @"act5"]){	userActionStorage[userActionId] = [userActionStorage[userActionId] intValue] > 1 ? @"0" : @"2"; [self templateUpdateStudioTerminal]; [self audioTerminalActive];}
	
	[self actionAnimation:sender];
	
}

- (IBAction)action2:(id)sender { // Decrement
	
	userActionStorage[userActionId] = [NSString stringWithFormat:@"%d", [ userActionStorage[userActionId] intValue]-1 ];
	NSLog(@"Action2");
	
}

- (IBAction)action3:(id)sender { // Warp Action
	
	[self audioDoorEnter];
	
	if	( userNode == 1 ){	userNode = 103; }
	else if	( userNode == 11 ){ userNode = 48; userOrientation = 2; }
	else if	( userNode == 13 ){ userNode = 12; }
	else if	( userNode == 12 ){	userNode = 13; }
	else if ( userNode == 16 ){	userNode = 22; }
	else if	( userNode == 23 ){	userNode = 22; }
	else if	( userNode == 25 ){	userNode = 31; userOrientation = 2;}
	else if	( userNode == 27 ){	userNode = 32; userOrientation = 1;}
	else if	( userNode == 35 ){	userNode = 31; userOrientation = 0;}
	else if	( userNode == 39 && userFold == 1 ) { userNode = 34; NSLog(@"!!"); }
	else if	( userNode == 39 ){	userNode = 45; }
	else if	( userNode == 45 ){	userNode = 51; }
	else if	( userNode == 46 ){	userNode = 85; userOrientation = 2; }
	else if	( userNode == 48 ){	userNode = 11; userOrientation = 2; }
	else if	( userNode == 51 ){	userNode = 45; }
	else if	( userNode == 52 ){	userNode = 32; userOrientation = 3;}
	else if	( userNode == 61 ){	userNode = 72; }
	else if	( userNode == 62 ){	userNode = 77; }
	else if	( userNode == 69 ){	userNode = 72; }
	else if	( userNode == 76 ){	userNode = 87; }
	else if	( userNode == 77 ){	userNode = 62; }
	else if	( userNode == 85 ){	userNode = 46; userOrientation = 0; }
	else if	( userNode == 87 ){	userNode = 76; }
	
	userAction = nil;
	
	[self actionCheck];
	[self moveCheck];
	
}

- (IBAction)action4:(id)sender { // Energy Action
	
	if( [self energyCount] > 0 ){
		userActionStorage[userActionId] = [NSString stringWithFormat:@"%d", [ userActionStorage[userActionId] intValue]+1 ];
	}
	else{
		[self audioEnergyStack];
		userActionStorage[userActionId] = @"0";
	}
	
	if( [userActionStorage[userActionId] intValue] > 4 ){
		[self audioEnergyInactive];
		userActionStorage[userActionId] = 0;
	}
	else{
		[self audioEnergyActive];
		userActionStorage[userActionId] = userActionStorage[userActionId];
	}
	
	[self templateUpdateEnergy];
	
}

- (IBAction)action5:(id)sender { // Seal Action
	
	if( [userActionStorage[userActionId] isEqual:@"1"] || [self sealCount] > 0 ){
		if( ![userActionStorage[userActionId] isEqual: @"1"] ){
			[self audioSealActive];
			userActionStorage[userActionId] = @"1";
		}
		else{
			[self audioSealInactive];
			userActionStorage[userActionId] = @"0";
		}
	}
	else{
		[self audioEnergyStack];
		NSLog(@"No more seal slots.");
	}
	
	[self templateUpdateSeal];
	
}

- (void)actionReset
{
	
	[_action1 setTitle:@"" forState:UIControlStateNormal];
	[_action2 setTitle:@"" forState:UIControlStateNormal];
	[_action3 setTitle:@"" forState:UIControlStateNormal];
	[_action4 setTitle:@"" forState:UIControlStateNormal];
	[_action5 setTitle:@"" forState:UIControlStateNormal];
	
	[self.action1 setImage: nil forState: UIControlStateNormal];
	[self.action2 setImage: nil forState: UIControlStateNormal];
	[self.action3 setImage: nil forState: UIControlStateNormal];
	[self.action4 setImage: nil forState: UIControlStateNormal];
	[self.action5 setImage: nil forState: UIControlStateNormal];
	
	self.action1.frame = CGRectMake(0, 0, 0, 0);
	self.action2.frame = CGRectMake(0, 0, 0, 0);
	self.action3.frame = CGRectMake(0, 0, 0, 0);
	self.action4.frame = CGRectMake(0, 0, 0, 0);
	self.action5.frame = CGRectMake(0, 0, 0, 0);
	
	self.graphic1.frame = CGRectMake(0, 0, 0, 0);
	self.graphic2.frame = CGRectMake(0, 0, 0, 0);
	self.graphic3.frame = CGRectMake(0, 0, 0, 0);
	self.graphic4.frame = CGRectMake(0, 0, 0, 0);
	self.graphic5.frame = CGRectMake(0, 0, 0, 0);
	self.graphic6.frame = CGRectMake(0, 0, 0, 0);
	self.graphic7.frame = CGRectMake(0, 0, 0, 0);
	self.graphic8.frame = CGRectMake(0, 0, 0, 0);
	self.graphic9.frame = CGRectMake(0, 0, 0, 0);
	self.graphic10.frame = CGRectMake(0, 0, 0, 0);
	self.graphic11.frame = CGRectMake(0, 0, 0, 0);
	self.graphic12.frame = CGRectMake(0, 0, 0, 0);
	self.graphic13.frame = CGRectMake(0, 0, 0, 0);
	self.graphic14.frame = CGRectMake(0, 0, 0, 0);
	self.graphic15.frame = CGRectMake(0, 0, 0, 0);
	self.graphic16.frame = CGRectMake(0, 0, 0, 0);
	self.graphic17.frame = CGRectMake(0, 0, 0, 0);
	
	[self rotate:self.action1 t:1.0 d:0];
	[self rotate:self.action3 t:1.0 d:0];
	
	[self fadeOut:self.graphic1 t:0];
	[self fadeOut:self.graphic2 t:0];
	[self fadeOut:self.graphic3 t:0];
	[self fadeOut:self.graphic4 t:0];
	[self fadeOut:self.graphic5 t:0];
	[self fadeOut:self.graphic6 t:0];
	[self fadeOut:self.graphic7 t:0];
	[self fadeOut:self.graphic8 t:0];
	[self fadeOut:self.graphic9 t:0];
	[self fadeOut:self.graphic10 t:0];
	[self fadeOut:self.graphic11 t:0];
	[self fadeOut:self.graphic12 t:0];
	[self fadeOut:self.graphic13 t:0];
	[self fadeOut:self.graphic14 t:0];
	[self fadeOut:self.graphic15 t:0];
	[self fadeOut:self.graphic16 t:0];
	[self fadeOut:self.graphic17 t:0];
	
	[self fadeOut:self.action1 t:0];
	[self fadeOut:self.action2 t:0];
	[self fadeOut:self.action3 t:0];
	[self fadeOut:self.action4 t:0];
	[self fadeOut:self.action5 t:0];
	
}

// ====================
// Actions with interactions
// ====================

- (void)templateUpdateSeal
{
	
	userSeal = [self sealCount];
	[self fadeOut:self.graphic1 t:1];
	
	if( [userActionStorage[userActionId] intValue] == 1 ){
		
		if( userSeal == 1 ){
			[self  templateUpdateNode:5:@"0493":@"act4"];
			[self  templateUpdateNode:38:@"0496":@"act12"];
			[self  templateUpdateNode:45:@"0502":@"act13"];
			[self  templateUpdateNode:49:@"0505":@"act21"];
			[self  templateUpdateNode:82:@"0499":@"act20"];
		}
		else{
			[self  templateUpdateNode:5:@"0494":@"act4"];
			[self  templateUpdateNode:38:@"0497":@"act12"];
			[self  templateUpdateNode:45:@"0503":@"act13"];
			[self  templateUpdateNode:49:@"0506":@"act21"];
			[self  templateUpdateNode:82:@"0500":@"act20"];
		}
		
	}
	
}

- (void)templateUpdateEnergy
{
	userEnergy = [self energyCount];
	self.graphic2.alpha = 0.3;
	self.graphic1.image = [UIImage imageNamed: [NSString stringWithFormat:@"energy_slot%d.png", [userActionStorage[userActionId] intValue] ] ];
	self.graphic2.image = [UIImage imageNamed: [NSString stringWithFormat:@"energy_userslot%d.png", userEnergy] ];
}

- (void)templateUpdateStudioTerminal
{
		
	if( [userActionStorage[userActionId] intValue] == 2 ){
		
		[self fadeIn:self.graphic1 t:1];
		
	}
	else{
		
		[self fadeOut:self.graphic1 t:1];
		
	}
	
}

- (void)templateUpdateForestGate
{
	
	[self fadeHalf:self.graphic1 t:1];
	self.graphic1.image = [UIImage imageNamed:@"seal32_metamondst.png"];
	self.graphic1.frame = CGRectMake(115, 140, 90, 90);
	
	[self fadeHalf:self.graphic2 t:1];
	self.graphic2.image = [UIImage imageNamed:@"seal32_rainre.png"];
	self.graphic2.frame = CGRectMake(115, 260, 90, 90);
	
	if ( [userActionStorage[20] intValue] == 1 ) {
		[self fadeIn:self.graphic1 t:1];
	}
	
	if ( [userActionStorage[13] intValue] == 1 ) {
		[self fadeIn:self.graphic2 t:1];
	}
		
}

- (void)templateUpdateState :(int)node :(NSString*)img :(NSString*)act
{
	if( userNode == node && [userAction isEqual: act]){
		[self.action3 setImage:[UIImage imageNamed: [NSString stringWithFormat:@"node.%@.jpg", img] ] forState:UIControlStateNormal];
	}
	self.action3.frame = CGRectMake(0, 10, 320, 460);
	[self fadeIn:self.action3 t:0.5];
}

- (void)templateUpdateNode :(int)node :(NSString*)img :(NSString*)act
{
	if( userNode == node && [userAction isEqual: act]){
		self.graphic1.image = [UIImage imageNamed: [NSString stringWithFormat:@"node.%@.jpg", img] ];
	}
	self.graphic1.frame = CGRectMake(0, 10, 320, 460);
	[self fadeIn:self.graphic1 t:0.5];

}

// ====================
// Counters
// ====================

- (int)energyCount
{
	userEnergy = 0;
	userEnergy += [userActionStorage[2] intValue];
	userEnergy += [userActionStorage[10] intValue];
	userEnergy += [userActionStorage[18] intValue];
	userEnergy += [userActionStorage[27] intValue];
	userEnergy = 4-userEnergy;
	
	return userEnergy;
}

- (int)sealCount
{
	userSeal = 0;
	userSeal += [userActionStorage[4] intValue];
	userSeal += [userActionStorage[12] intValue];
	userSeal += [userActionStorage[13] intValue];
	userSeal += [userActionStorage[14] intValue];
	userSeal += [userActionStorage[20] intValue];
	userSeal += [userActionStorage[21] intValue];
	userSeal = 2-userSeal;
	
	return userSeal;
}

- (int)collectibleCount
{
	userCollectible = 0;
	userCollectible += [userActionStorage[31] intValue];
	userCollectible += [userActionStorage[32] intValue];
	userCollectible += [userActionStorage[33] intValue];
	userCollectible += [userActionStorage[34] intValue];
	userCollectible += [userActionStorage[35] intValue];
	userCollectible += [userActionStorage[37] intValue];
	userCollectible += [userActionStorage[38] intValue];
	userCollectible += [userActionStorage[39] intValue];
	userCollectible += [userActionStorage[40] intValue];
	userCollectible += [userActionStorage[41] intValue];
	
	return userCollectible;
}

// ====================
// Tools
// ====================

-(void)fadeIn:(UIView*)viewToFadeIn t:(NSTimeInterval)duration
{
	[UIView beginAnimations: @"Fade In" context:nil];
	[UIView setAnimationDuration:duration];
	viewToFadeIn.alpha = 1;
	[UIView commitAnimations];
}

-(void)fadeOut:(UIView*)viewToFadeOut t:(NSTimeInterval)duration
{
	[UIView beginAnimations: @"Fade Out" context:nil];
	[UIView setAnimationDuration:duration];
	viewToFadeOut.alpha = 0;
	[UIView commitAnimations];
}
-(void)fadeHalf:(UIView*)viewToFadeOut t:(NSTimeInterval)duration
{
	[UIView beginAnimations: @"Fade Half" context:nil];
	[UIView setAnimationDuration:duration];
	viewToFadeOut.alpha = 0.2;
	[UIView commitAnimations];
}
- (void)rotate:(UIButton *)viewToRotate t:(NSTimeInterval)duration d:(CGFloat)degrees
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationBeginsFromCurrentState:YES];
	CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
	viewToRotate.transform = transform;
	[UIView commitAnimations];
}

-(void)turnLeft
{
	self.viewMain.alpha = 0.5;
	self.viewMain.transform = CGAffineTransformMakeTranslation(-15, 0);
	
	[UIView beginAnimations: @"Turn Left" context:nil];
	[UIView setAnimationDuration:0.2];
	self.viewMain.transform = CGAffineTransformMakeTranslation(0, 0);
	self.viewMain.alpha = 1;
	[UIView commitAnimations];
}

-(void)turnRight
{
	self.viewMain.alpha = 0.5;
	self.viewMain.transform = CGAffineTransformMakeTranslation(15, 0);
	
	[UIView beginAnimations: @"Turn Right" context:nil];
	[UIView setAnimationDuration:0.2];
	self.viewMain.transform = CGAffineTransformMakeTranslation(0, 0);
	self.viewMain.alpha = 1;
	[UIView commitAnimations];
}

-(void)turnForward
{
	self.viewMain.alpha = 0.5;
	self.viewMain.transform = CGAffineTransformMakeTranslation(0, 2);
	
	[UIView beginAnimations: @"Turn Right" context:nil];
	[UIView setAnimationDuration:0.2];
	self.viewMain.transform = CGAffineTransformMakeTranslation(0, 0);
	self.viewMain.alpha = 1;
	[UIView commitAnimations];
}

-(void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

// ====================
// Audio
// ====================

-(void)audioRouterMove
{
	userFootstep += 1;
	if ( [worldPath[userNode][userOrientation] rangeOfString:@"|"].location != NSNotFound || [worldPath[userNode][userOrientation] intValue] > 0) {
		if (userFootstep & 1) {
			[self audioFootLeft];
		} else {
			[self audioFootRight];
		}
	}
	else {
		[self audioCollide];
	}	
}

@end