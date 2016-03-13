
#import <Foundation/Foundation.h>

@interface BTLECentralViewController : NSObject

@property (nonatomic, weak) id delegate;

@property NSString *identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier;

@end
