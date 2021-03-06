//
//  ParseConfXMLInfo.mm
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import "ParseConfXMLInfo.h"
//#import "ECSUtils.h"
//#import "ECSAppConfig.h"

static NSString * const kIdElementName = @"id";
static NSString * const kConfTypeElementName = @"conftype";
static NSString * const kAttendeeNumElementName = @"attendeenum";
static NSString * const kAttendeeTypeElementName = @"attendeetype";
static NSString * const kDataConfUrlElementName = @"dataconfurl";
static NSString * const kTokenElementName = @"token";
static NSString * const kTimestamp = @"timestamp";
static NSString * const kSiteIdElementName = @"siteid";
static NSString * const kHostKeyElementName = @"hostkey";
static NSString * const kCmAddressElementName = @"cmAddress";

static NSString * const kUportalIdElementName = @"conf_id";
static NSString * const kUPortalUserTypeElementName = @"user_role";
static NSString * const kUportalUserIdElementName = @"user_id";
static NSString * const kUportalConfTypeElementName = @"conf_type";
static NSString * const kUportalAttendeeNumElementName = @"user_uri";
//static NSString * const kUportalAttendeeTypeElementName = @"";
static NSString * const kUportalDataConfUrlElementName = @"server_ip";
static NSString * const kUportalTokenElementName = @"crypt_key";
//static NSString * const kUportalTimestamp = @"";
static NSString * const kUportalSiteIdElementName = @"site_id";
static NSString * const kUportalHostKeyElementName = @"host_key";
static NSString * const kUportalCmAddressElementName = @"cm_address";

static NSString * const kUportalUserMElementName = @"M";
static NSString * const kUportalUserTElementName = @"T";
static NSString * const KUportalSBCServerIPAddress = @"sbc_server_address";

@implementation multiConfUCV2
@synthesize token;
@synthesize confID;
@synthesize confURL;
@synthesize timestamp;
@synthesize siteID;
@synthesize attendeeNum;
@synthesize hostRole;
//-(void)setHostRole:(NSString *)aHostRole{
//    hostRole = [ECSUtils plistDataEncrypt:aHostRole];
//}
//-(NSString*)hostRole{
////    return [ECSUtils plistDataDecrypt:hostRole];
//}
@synthesize cmAddress;



@end


@interface ParseConfXMLInfo()

-(void)configId:(NSString*)aStr;
-(void)configConfType:(NSString*)aStr;
-(void)configAttendeeNum:(NSString*)aStr;
-(void)configAttendeeType:(NSString*)aStr;
-(void)configDataConfUrl:(NSString*)aStr;
-(void)configToken:(NSString*)aStr;
-(void)configTimestamp:(NSString*)aStr;
-(void)configSiteId:(NSString*)aStr;
-(void)configHostKey:(NSString*)aStr;
-(void)clearConfInfo;
@end




@implementation ParseConfXMLInfo	 
#pragma mark -
#pragma mark life circle
-(id)init
{
	if (self = [super init]) {
		confParm = [[multiConfUCV2 alloc] init];
	}
	return self;
}


#pragma mark -
#pragma mark interface
-(multiConfUCV2*)parseUCV2ConfData:(NSString*)confData
{
	if ([confData length]<=0) {
		return nil;
	}
	[self clearConfInfo];	//????????????
	NSString *originStr = confData;
    //maa??????????????????????????????????????????????????????

    NSString *parserStr = [NSString stringWithFormat:@"<root>%@</root>",originStr]; //??????????????????

	NSData *parseData = [parserStr dataUsingEncoding:NSUTF8StringEncoding];
	
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:parseData];
	[parser setDelegate:self];
	
	[parser parse];  //????????????confparm??????
	
	
	return confParm;
}


#pragma mark -
#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	[currentStringValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
        if ([elementName isEqualToString:kUportalIdElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configId:str];
        }
        
        if ([elementName isEqualToString:kUportalConfTypeElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configConfType:str];
        }
        
        if ([elementName isEqualToString:kUportalAttendeeNumElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configAttendeeNum:str];
        }
        
        
        if ([elementName isEqualToString:kUportalDataConfUrlElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configDataConfUrl:str];
        }
        
        if ([elementName isEqualToString:kUportalTokenElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configToken:str];
        }
        
        
        if ([elementName isEqualToString:kUportalSiteIdElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configSiteId:str];
        }
        
        if ([elementName isEqualToString:kUportalHostKeyElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configHostKey:str];
        }
        
        if ([elementName isEqualToString:kUportalCmAddressElementName]) {
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configCmAddress:str];
        }
        
        if ([elementName isEqualToString:kUPortalUserTypeElementName]){
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configUserType:str];
        }
        
        if ([elementName isEqualToString:kUportalUserMElementName]){
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configUserM:str];
        }
        
        if ([elementName isEqualToString:kUportalUserTElementName]){
            NSString *str = [currentStringValue stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self configUserT:str];
        }
        

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        currentStringValue = [[NSMutableString alloc] initWithCapacity:0];
    }
    
    [currentStringValue appendString:string];
}
#pragma mark -
#pragma mark private methods
-(void)configId:(NSString*)aStr
{
	confParm.confID = aStr;
}

- (void)configUserType:(NSString *)aStr
{
    confParm.userType = aStr;
}

- (void)configUserM:(NSString *)aStr
{
    confParm.userM = aStr;
}

- (void)configUserT:(NSString *)aStr
{
    confParm.userT = aStr;
}

- (void)configSbcServerIP:(NSString *)aStr
{
    confParm.sbcServerIP = aStr;
}

-(void)configConfType:(NSString*)aStr{
}
-(void)configAttendeeNum:(NSString*)aStr
{
	confParm.attendeeNum = aStr;
}
-(void)configAttendeeType:(NSString*)aStr{
}
-(void)configDataConfUrl:(NSString*)aStr
{
	confParm.confURL = aStr;
}
-(void)configToken:(NSString*)aStr
{
    //????????????token
	confParm.token = aStr;
}
-(void)configTimestamp:(NSString*)aStr
{
	confParm.timestamp = aStr;
}
-(void)configSiteId:(NSString*)aStr
{
	confParm.siteID = aStr;
}

-(void)configHostKey:(NSString *)aStr
{
	confParm.hostRole = aStr;
}

-(void)configCmAddress:(NSString *)aStr
{
	confParm.cmAddress = aStr;
}

-(void)clearConfInfo
{
	confParm.confID = [NSString string];
	confParm.confURL = [NSString string];
	confParm.siteID = [NSString string];
	confParm.timestamp = [NSString string];
	confParm.token = [NSString string];
	confParm.attendeeNum = [NSString string];
	confParm.hostRole = [NSString string];
}



@end
