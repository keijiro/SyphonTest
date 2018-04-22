#import "LiteClient.h"
#import "SyphonPrivate.h"
#import "SyphonServerDirectory.h"
#import "SyphonClientConnectionManager.h"
#import <Metal/MTLDevice.h>
#import <Metal/MTLTexture.h>

@interface LiteClient()
{
    SyphonClientConnectionManager* _connection;
    id<MTLTexture> _texture;
}
@end

@implementation LiteClient

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithServerDescription:(NSDictionary *)description
{
    if (self = [super init])
    {
        _connection = [[SyphonClientConnectionManager alloc] initWithServerDescription:description];
        if (_connection == nil)
        {
            [self release];
            return nil;
        }
        [_connection addInfoClient:(id<SyphonInfoReceiving>)self isFrameClient:NO];
    }
    return self;
}

- (void)dealloc
{
    [_connection removeInfoClient:(id<SyphonInfoReceiving>)self isFrameClient:NO];
    [_connection release];
    if (_texture) [_texture release];
    [super dealloc];
}

- (void)invalidateFrame
{
}

- (void)updateFromRenderThread:(id<MTLDevice>)device
{
    IOSurfaceRef surface = [_connection surfaceHavingLock];

    if (_texture)
    {
        if (_texture.iosurface != surface)
        {
            [_texture release];
            _texture = nil;
        }
    }
    
    if (!_texture && surface)
    {
        MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                        width:IOSurfaceGetWidth(surface)
                                                                                       height:IOSurfaceGetHeight(surface)
                                                                                    mipmapped:NO];
        _texture = [device newTextureWithDescriptor:desc iosurface:surface plane:0];
    }
}

@end