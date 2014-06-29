//
//  AppDelegate.m
//  Json2File
//
//  Created by NguyenTheQuan on 2014/05/14.
//  Copyright (c) 2014年. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    _classHeaderArray = [[NSMutableArray alloc] init];
    _classImpleArray = [[NSMutableArray alloc] init];
}

- (IBAction)convertButtonClick:(id)sender
{
    [_classHeaderArray removeAllObjects];
    [_classImpleArray removeAllObjects];
    _mainClassName = [self uppercaseFirstLetter:_fileName.stringValue];
    NSData *jsonData = [_jsonCodeTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) return;
    
    [self createClass:jsonDict withClassName:_mainClassName];
    
    [self saveHeaderFile];
    [self saveImplementFile];
}

- (void)createClass:(NSDictionary *)dictionary withClassName:(NSString *)className
{
    NSString *classHeaderContent = [NSString stringWithFormat:@"\n\n\n"
                                                               "@interface %@ : NSObject\n",
                                                                className];
    
    NSString *classImpleContent = [NSString stringWithFormat:@"\n\n\n"
                                   "@implementation %@"
                                   "\n\n- (id)initWithData:(NSDictionary *)data"
                                   "\n{"
                                   "\n\tself = [super init];"
                                   "\n\tif (self) {\n",
                                    className];
    
    
    NSString *proString = @"";
    NSString *initString = @"";
    
    for (NSString *key in [dictionary allKeys]) {
        id obj = dictionary[key];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *className = [NSString stringWithFormat:@"%@%@",
                                   _mainClassName,
                                   [self formatName:key]];
            
            [self createClass:dictionary[key] withClassName:className];
            proString = [NSString stringWithFormat:@"\n@property (nonatomic, readonly) %@ *%@;", className, key];
            initString = [NSString stringWithFormat:@"\n\t\tself.%@ = [[%@ init] initWithData:data[@\"%@\"]];",key,className,key];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            NSString *className = [NSString stringWithFormat:@"%@%@",
                                   _mainClassName,
                                   [self formatName:key]];
            
            NSArray *array = dictionary[key];
            [self createClass:[array objectAtIndex:0] withClassName:className];
            proString = [NSString stringWithFormat:@"\n@property (nonatomic, readonly) NSMutableArray *%@;", key];
            
            initString = [NSString stringWithFormat:
                          @"\n\t\tself.%@ = [[NSMutableArray alloc] init];"
                          "\n\t\tfor (NSDictionary *dictionary in data[@\"%@\"]) {"
                          "\n\t\t\t%@ *item = [[%@ alloc] initWithData:dictionary];"
                          "\n\t\t\t[self.%@ addObject:item];"
                          "\n\t\t}",
                          key, key, className, className, key];
            
        }
        else {
            id obj = dictionary[key];
            NSString *type = @"";
            if ([obj isKindOfClass:[NSString class]]) {
                type = @"NSString";
            }
            else {
                type = NSStringFromClass([obj superclass]);
            }
            //type = [type stringByReplacingOccurrencesOfString:@"__NSCF" withString:@"NS"];
            NSString *validKey = ([key isEqualToString:@"id"]) ? @"Id" : key; //check if key = id
            proString = [NSString stringWithFormat:@"\n@property (nonatomic, readonly) %@ *%@;", type, validKey];
            initString = [NSString stringWithFormat:@"\n\t\tself.%@ = data[@\"%@\"];",validKey,key];
        }
        
        classHeaderContent = [NSString stringWithFormat:@"%@%@",classHeaderContent,proString];
        classImpleContent = [NSString stringWithFormat:@"%@%@",classImpleContent,initString];
    }
    
    
    
    classHeaderContent = [NSString stringWithFormat:@"%@\n\n- (id)initWithData:(NSDictionary *)data;"
                          "\n\n@end",classHeaderContent];
    
    classImpleContent = [NSString stringWithFormat:@"%@\n\t}"
                         "\n\n\treturn self;"
                         "\n}"
                         "\n\n@end"
                         ,classImpleContent];
    
    [_classHeaderArray addObject:classHeaderContent];
    [_classImpleArray addObject:classImpleContent];
}

- (void)saveHeaderFile
{
    //Header file
    NSString *filepath = [NSString stringWithFormat:@"~/Desktop/%@.h",_mainClassName];
    filepath = [filepath stringByExpandingTildeInPath];
    NSString *content = @"\n\n\n"
                        "#import <Foundation/Foundation.h>";
    
    NSString *classContents = [_classHeaderArray componentsJoinedByString:@""];
    
    content = [NSString stringWithFormat:@"%@%@",content,classContents];
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filepath
                                            contents:fileContents
                                          attributes:nil];
    
}

- (void)saveImplementFile
{
    NSString *filepath = [NSString stringWithFormat:@"~/Desktop/%@.m",_mainClassName];
    filepath = [filepath stringByExpandingTildeInPath];
    NSString *content = [NSString stringWithFormat:@"\n\n\n"
                                                    "#import \"%@.h\"",
                                                    _mainClassName];
    
    NSString *classContents = [_classImpleArray componentsJoinedByString:@""];
    
    content = [NSString stringWithFormat:@"%@%@",content,classContents];
    NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filepath
                                            contents:fileContents
                                          attributes:nil];
}

- (NSString *)formatName:(NSString *)name
{
    NSString *formatedName = @"";
    NSArray *array = [name componentsSeparatedByString:@"_"];
    for (NSString *str in array) {
        formatedName = [NSString stringWithFormat:@"%@%@", formatedName, [self uppercaseFirstLetter:str]];
    }
    
    return formatedName;
}

- (NSString *)uppercaseFirstLetter:(NSString *)inputString
{
    NSString *capitalisedSentence;
    
    if (inputString && [inputString length]>0) {
        
        capitalisedSentence = [inputString stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                  withString:[[inputString substringToIndex:1] capitalizedString]];
    }
    else{
        
        capitalisedSentence = @"";
    }
    
    return capitalisedSentence;
}

@end
