//
//  WPCategoryTree.m
//  WordPress
//
//  Created by JanakiRam on 30/01/09.

#import "WPCategoryTree.h"

@implementation WPCategoryTree

- (id)initWithParent:(id)aParent {
    if (self = [super init]) {
        parent = aParent;
        children = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)getChildrenFromObjects:(NSArray *)collection {
    NSUInteger count = [collection count];

    for (NSInteger i = 0; i < count; i++) {
        NSDictionary *category = [collection objectAtIndex:i];

        if ([[category valueForKey:@"parentID"] intValue] ==[[parent valueForKey:@"categoryID"] intValue]) {
            WPCategoryTree *child = [[WPCategoryTree alloc] initWithParent:category];
            [child getChildrenFromObjects:collection];
            [children addObject:child];
        }
    }
}


- (NSArray *)getAllObjects {
    NSMutableArray *allObjects = [NSMutableArray array];
    NSUInteger count = [children count];

    if (parent) {
        [allObjects addObject:parent];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        [allObjects addObjectsFromArray:[[children objectAtIndex:i] getAllObjects]];
    }

    return allObjects;
}

@end
