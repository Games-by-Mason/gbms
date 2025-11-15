#ifndef INCLUDE_GBMS_LINK
#define INCLUDE_GBMS_LINK

// GLSL expects you to define your shaders in separate files, which is unfortunate because they are
// often tightly coupled to each other anyway. You can't quite use Vulkan's named entry points to
// solve this since you may use features in one entry point that fail compilation in other stages,
// but you *can* put all entry points in one stage by wrapping them in preprocessor conditionals!
//
// Assuming you've done that, you'll quickly tire of writing all your in/out variables twice. This
// header provides some macros to reduce the boilerplate.
//
// A useful convention is to prefix these link variables with `l_` since they have the same name
// everywhere, so you can no longer prefix them with `in_`/`out_` as is often conventional.
//
// Optional qualifiers like `flat` can precede the variable name, e.g.:
// ```
// LINK_VERT_FRAG(location = 3) flat Entity l_entity;
// ```

#ifdef GL_VERTEX_SHADER
    #define LINK_VERT_FRAG(_layout) layout(_layout) out
#elif GL_FRAGMENT_SHADER
    #define LINK_VERT_FRAG(_layout) layout(_layout) in
#endif

#endif
